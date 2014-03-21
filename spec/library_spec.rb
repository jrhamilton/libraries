require 'book'
require 'author'
require 'catalog'
require 'pg'


DB = PG.connect(:dbname => 'library_test')

RSpec.configure do |config|
  config.after(:each) do
    DB.exec('DELETE FROM books *;')
    DB.exec('DELETE FROM authors *;')
    DB.exec('DELETE FROM catalog *;')
  end
end


describe Book do
  describe 'initialize' do
    it 'should initialize with a title and author id' do
      test_book = Book.new('title' => 'The Book')
      test_book.should be_an_instance_of Book
      test_book.title.should eq 'The Book'
    end
  end

  describe 'save' do
    it 'should save a book to the database' do
      test_book = Book.new('title' => 'Another Book')
      test_book.save
      Book.all.should eq [test_book]
    end
  end

  describe '==' do
    it 'should recognize books with the same title and author_id as the same book object' do
      test_book = Book.new('title' => 'Another Book')
      test_book2 = Book.new('title' => 'Another Book')
      test_book.should eq test_book2
    end
  end

  describe 'get_authors' do
    it 'should return the authors name based on id from join table' do
      test_book = Book.new('title' => 'Another Book')
      test_author = Author.new('author' => 'author dude')
      test_catalog = Catalog.new('book_id' => test_book.id,'author_id' => test_author.id)
      authors = test_book.get_authors
      authors[0].author.should eq 'author dude'
    end
  end

  describe 'update_title' do
    it 'should update the title of the book in the database' do
      test_book = Book.new('title' => 'Old Title')
      test_book.update_title('New Title')
      test_book.title.should eq 'New Title'
    end
  end

  describe 'delete' do
    it 'should delete a book from the database' do
      test_book = Book.new('title' => 'New Title')
      test_book.delete
      Book.all.should eq []
    end
  end

end

describe Author do
  describe 'initialize' do
    it 'initializes an author' do
      test_author = Author.new('author' => 'author dude')
      test_author.save
      Author.all.should eq [test_author]
    end
  end
  describe 'save' do
    it 'should save an author to the database' do
      test_author = Author.new('author' => 'author 1')
      test_author.save
      Author.all.should eq [test_author]
    end
  end

  describe '==' do
    it 'should recognize books with the same title and author_id as the same book object' do
      test_author = Author.new('author' => 'Arther')
      test_author2 = Author.new('author' => 'Arther')
      test_author.should eq test_author2
    end
  end
end

describe Catalog do
  describe 'initialize' do
    it 'should initialize with a book_id and author_id' do
      test_catalog = Catalog.new('book_id' => 2,'author_id' => 3)
      test_catalog.author_id.should eq 3
      test_catalog.book_id.should eq 2
      test_catalog.should be_an_instance_of Catalog
    end
  end

  describe 'save' do
    it 'saves a Catalog entry to the database' do
      test_catalog = Catalog.new('book_id' => 2,'author_id' => 3)
      Catalog.all.should eq [test_catalog]
    end
  end

  describe 'Catalog.find' do
    it 'create an catalog object for the inputted book and author ids' do
      test_book = Book.new('Book Title')
      test_author = Author.new('Book Author')
      catalog_entry = Catalog.new({'book_id' => test_book.id, 'author_id' => test_author.id})
      Catalog.find(test_book.id, test_author.id).should eq catalog_entry
    end
  end

  describe 'Catalog.update_author' do
    it 'updates the author for a book in the catalog table' do
      test_book = Book.new('Book Title')
      test_author = Author.new('Book Author')
      new_author = Author.new('New Author')
      new_catalog = Catalog.update_author(test_book.id, test_author.id, new_author.id)
      new_catalog.author_id.should eq new_author.id
    end
  end

  describe 'Catalog.add_author' do
    it 'adds another author to a book. new catalog entry' do
      test_book = Book.new('Book Title')
      new_author = "New Author"
      new_catalog = Catalog.add_author(test_book.id, new_author)
      new_catalog.author_id.should be_an_instance_of Fixnum
    end
  end

  describe 'self.search_author' do
    it 'returns all books by a particular author' do
      test_book = Book.new('title'=>'Book Title')
      test_author = Author.new('author' => 'Book Author')
      catalog_entry = Catalog.new({'book_id' => test_book.id, 'author_id' => test_author.id})
      Catalog.search_author('Book Author').should eq [test_book]
    end
  end

  describe 'self.search_title' do
    it 'returns all books matching a particular title' do
      test_book = Book.new('title'=>'Book Title')
      test_author = Author.new('author' => 'Book Author')
      catalog_entry = Catalog.new({'book_id' => test_book.id, 'author_id' => test_author.id})
      Catalog.search_title('Book Title').should eq [test_book]
    end
  end
end
