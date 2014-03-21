class Author

  attr_reader :author, :id

  def initialize(hash)
    @author = hash['author']
    @id = hash['id']
    save
  end

  def save
    check = DB.exec("SELECT * FROM authors WHERE author = '#{@author}';")
    if check.first == nil
      results = DB.exec("INSERT INTO authors (author) VALUES ('#{@author}') RETURNING id;")
      @id = results.first['id'].to_i
    else
      @id = check.first['id']
    end
  end

  def self.all
    results = DB.exec("SELECT * FROM authors;")
    authors = []
    results.each do |result|
      author = result['author']
      id = result['id']
      authors << Author.new({'author' => author, 'id' => id})
    end
    authors
  end

  def ==(another_author)
    @author == another_author.author
  end


end
