require './lib/book'
require './lib/author'
require './lib/catalog'
require 'pg'
require 'pry'


DB = PG.connect(:dbname => 'library')


def main_menu
  puts "B - for All Books"
  puts "A - for All Authors"
  choice = gets.chomp.upcase
  case choice
  when 'B'
    system('clear')
    books_menu
  when 'A'
    system('clear')
    authors_menu
  else
    puts "Try again"
    main_menu
  end
end

def books_menu
  if Book.all.empty?
    puts "No books in system.  Add a book first."
  else
   list_books
  end
  puts "\n"
  puts "A - to add a book"
  puts "E - to edit a book"
  puts "D - to Delete a book"
  puts "M - to return to main menu"
  choice = gets.chomp.upcase
  case choice
  when 'A'
    system('clear')
    add_book
  when 'E'
    system('clear')
    edit_book
  when 'D'
    system('clear')
    delete_book
  when 'M'
    system('clear')
    main_menu
  end
end

def add_book
  puts "What is title of the book to add?"
  title = gets.chomp
  puts "Who is the author of #{title}?"
  author = gets.chomp
  author = Author.new('author'=>author)
  book = Book.new('title'=>title)
  new_catalog = Catalog.new('book_id' => book.id, 'author_id' => author.id)
  system('clear')
  puts "Book added"
  main_menu
end

def edit_book
  list_books
  puts "\n"
  puts "Choose ID of book to edit?"
  id = gets.chomp.to_i - 1
  current_book = Book.all[id]
  puts "Enter new title for #{current_book.title} or leave blank to keep the same."
  new_book_title = gets.chomp
  if new_book_title != ''
    current_book.update_title(new_book_title)
  end
  authors = current_book.get_authors
  puts_authors_with_index(authors)
  puts "\n"
  puts "A - to add an author"
  puts "E - to edit an author"
  puts "D - to delete an author"
  puts "B - to go back to Books Menu"
  choice = gets.chomp.upcase
  case choice
    when 'A'
      add_book_author(current_book)
    when 'E'
      edit_book_author(current_book)
    when 'D'
      delete_book_author(current_book)
    when 'B'
      system('clear')
      books_menu
  else
    puts "Try again."
    edit_book
  end

  # puts "Enter new author name for #{current_book.title} or leave blank to keep the same"
  # new_book_author = gets.chomp
  # if new_book_author != ''
  #   current_book.update_author(new_book_author)
  # end
  system('clear')
  puts "Book has been update"
  main_menu
end

def delete_book
  list_books
  puts "Select a book to delete"
  book_delete = gets.chomp.to_i - 1
  current_book = Book.all[book_delete]

  current_book.delete
  puts "Book deleted."
  books_menu
end


def authors_menu


end


# Helper methods

def list_books
  puts "Current Books:"
  Book.all.each_with_index do |book, index|
    #auth_objs =
    #authors = puts_authors(book.get_authors)
    print "#{index + 1}.  Title: #{book.title},"
    puts_authors(book.get_authors)
    print "\n"
  end
end

def puts_authors(authors)
  authors.each do |author|
    print "\tAuthor: #{author.author}"
  end
end

def puts_authors_with_index(authors)
  authors.each_with_index do |author, index|
    puts "#{index + 1}: #{author.author}"
  end
end

def add_book_author(book)
  puts "Enter another author for this book"
  user_input = gets.chomp
  Catalog.add_author(book.id, user_input)
  system('clear')
  puts "#{user_input} has been added to #{book.title}"
  edit_book
end



def edit_book_author(book)
  puts "Enter ID of author you want to edit"
  user_input = gets.chomp.to_i - 1
  puts "Enter a new author name for this book"
  new_author = gets.chomp
  current_author = Author.all[user_input]
  catalog_obj = Catalog.find(book.id, current_author.id)
  new_author_obj = Author.new('author' => new_author)
  Catalog.update_author(catalog_obj.book_id, catalog_obj.author_id, new_author_obj.id)

  puts "Book updated with #{current_author.author}"
  main_menu
end

def delete_book_author(book)
  puts "Enter ID of author to remove from #{book.title}"
  input = gets.chomp.to_i - 1
  author = Author.all[input]
  Catalog.remove_author_from_book(book.id, author.id)
  system('clear')
  puts "#{author.author} has been removed from #{book.title}"
  edit_book
end

main_menu

