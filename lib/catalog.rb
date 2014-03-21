class Catalog

attr_reader :id, :book_id, :author_id

  def initialize(hash)
    @book_id = hash['book_id']
    @author_id = hash['author_id']
    @id = hash['id']
    save
  end

  def save
    check = DB.exec("SELECT * FROM catalog WHERE book_id = #{@book_id} AND author_id = #{@author_id};")
    if check.first == nil
      results = DB.exec("INSERT INTO catalog (book_id, author_id) VALUES (#{@book_id}, #{@author_id}) RETURNING id;")
      @id = results.first['id'].to_i
    else
      @id =check.first['id'].to_i
    end
  end

  def self.all
    results = DB.exec("SELECT * FROM catalog;")
    catalog = []
    results.each do |result|
      book_id = result['book_id'].to_i
      author_id = result['author_id'].to_i
      id = result['id'].to_i
      catalog << Catalog.new({'book_id' => book_id, 'author_id' => author_id, 'id' => id})
    end
    catalog
  end

  def ==(another_catalog)
    @book_id == another_catalog.book_id && @author_id == another_catalog.author_id
  end


  def Catalog.update_author(book_id, old_author_id, new_author_id)
    DB.exec("DELETE FROM catalog WHERE author_id = #{old_author_id} AND book_id = #{book_id};")
    newCatalog = Catalog.new('book_id' => book_id, 'author_id' => new_author_id)
    #DB.exec("INSERT INTO catalog (book_id, author_id) VALUES (#{book_id}, #{new_author_id});")
  end

  def Catalog.find(book_id, author_id)
    puts book_id
    puts author_id
    results = DB.exec("SELECT * FROM catalog WHERE book_id = #{book_id} AND author_id = #{author_id};")
    catalogs = []
    results.each do |result|
      id = result['id']
      book_id = result['book_id'].to_i
      author_id = result['author_id'].to_i
      catalogs << Catalog.new({'id' => id, 'book_id' => book_id, 'author_id' => author_id})
    end
    catalogs.first
  end

  def self.add_author(book_id, new_author_name)
    new_author = Author.new('author' => new_author_name)
    Catalog.new('book_id' => book_id, 'author_id' => new_author.id)
  end

  def self.remove_author_from_book(book_id, author_id)
    DB.exec("DELETE FROM catalog WHERE book_id = #{book_id} AND author_id = #{author_id};")
  end

  def self.search_author(author_name)
    results = DB.exec("SELECT books.* FROM authors JOIN catalog ON (authors.id = catalog.author_id) JOIN books ON (catalog.book_id = books.id) WHERE authors.author = '#{author_name}';")
    books = []
    results.each do |result|
      title = result['title']
      books << Book.new('title' => title)
    end
    books
  end

  def self.search_title(book_title)
    results = DB.exec("SELECT * FROM books WHERE title = '#{book_title}';")
    books = []
    results.each do |result|
      title = result['title']
      books << Book.new('title' => title)
    end
    books
  end
end
