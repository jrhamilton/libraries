class Book

  attr_reader :id, :title, :copies, :checked_out

  def initialize(hash)
    @id = hash['id']
    @title = hash['title']
    @copies = 0
    @checked_out = 0
    save
  end

  def save
    check = DB.exec("SELECT * FROM books WHERE title = '#{@title}';")
    if check.first == nil
      results = DB.exec("INSERT INTO books (title) VALUES ('#{@title}') RETURNING id;")
      @id = results.first['id'].to_i
      # DB.exec("INSERT INTO catalog (book_id, author_id)")
    else
      @id = check.first['id']
    end
  end

  def self.all
    results = DB.exec("SELECT * FROM books;")
    books = []
    results.each do |result|
      title = result['title']
      id = result['id'].to_i
      books << Book.new({'title' => title, 'id' => id})
    end
    books
  end

  def ==(another_book)
    @title == another_book.title
  end

  def get_authors
    results = DB.exec("SELECT * FROM catalog join authors on (catalog.author_id = authors.id ) WHERE catalog.book_id = #{@id};")
    authors = []
    results.each do |result|
      author = result['author']
      authors << Author.new('author' => author)
    end
    authors
  end

  def update_title(new_title)
    DB.exec("UPDATE books set title = '#{new_title}' where id = #{@id};")
    @title = new_title
  end

  def delete
    DB.exec("DELETE FROM books WHERE id = #{@id};")
  end

end
