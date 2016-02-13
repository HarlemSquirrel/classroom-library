class BooksController < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    register Sinatra::ActiveRecordExtension
    register Sinatra::Flash
    set :session_secret, "secret"
  end

  get '/books' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @user = User.find(session[:id])
    @session = session
    @books = Book.all
    erb :'books/books'
  end

  get '/books/new' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @user = User.find(session[:id])
    @authors = Author.all
    @genres = Genre.all
    @session = session
    erb :'books/new_book'
  end

  post '/books' do
    if params[:title] == ""
      flash[:error] = "You must enter a title"
      redirect to '/books/new'
    end

    if params[:select_author] == "NEW"
      if params[:new_author] == ""
        flash[:error] = "Enter an author"
        redirect to '/books/new'
      end
      author = Author.find_or_create_by(name: params[:new_author])
    else
      author = Author.find_by(name: params[:select_author])
    end

    if params[:select_genre] == "NEW"
      if params[:new_genre] == ""
        flash[:error] = "Enter a genre"
        redirect to '/books/new'
      end
      genre = Genre.find_or_create_by(name: params[:new_genre])
    else
      genre = Genre.find_by(name: params[:select_genre])
    end

    book = Book.create(
      title: params[:title],
      author: author,
      genre: genre,
      user: Helpers.current_user(session),
      on_loan_to: ""
    )

    redirect to "/books"
  end

  get '/books/:id' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @session = session
    @book = Book.find(params[:id])
    @user = User.find(session[:id])
    erb :'books/show_book'
  end

  get '/books/:id/delete' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @session = session
    @book = Book.find(params[:id])
    @user = User.find(session[:id])
    erb :'books/delete_book'
  end

  post '/books/:id/delete' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    book = Book.find(params[:id])
    book.delete
    redirect to '/books'
  end

  get '/books/:id/edit' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @session = session
    @book = Book.find(params[:id])
    @user = User.find(session[:id])
    @authors = Author.all
    @genres = Genre.all
    erb :'books/edit_book'
  end

  get '/books/:id/lend' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @session = session
    @book = Book.find(params[:id])
    @user = User.find(session[:id])
    @authors = Author.all
    @genres = Genre.all
    erb :'books/lend_book'
  end

  get '/books/:id/return_book' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @session = session
    @book = Book.find(params[:id])
    @user = User.find(session[:id])
    @authors = Author.all
    @genres = Genre.all
    erb :'books/return_book'
  end

  patch '/books/:id' do
    if params[:title] == ""
      flash[:error] = "Enter a title"
      redirect to "/books/#{book.id}/edit"
    end
    book = Book.find(params[:id])

    if params[:select_author] == "NEW"
      if params[:new_author] == ""
        flash[:error] = "Enter an author"
        redirect to "/books/#{book.id}/edit"
      end
      author = Author.find_or_create_by(name: params[:new_author])
    else
      author = Author.find_by(name: params[:select_author])
    end

    if params[:select_genre] == "NEW"
      if params[:new_genre] == ""
        flash[:error] = "Enter a genre"
        redirect to "/books/#{book.id}/edit"
      end
      genre = Genre.find_or_create_by(name: params[:new_genre])
    else
      genre = Genre.find_by(name: params[:select_genre])
    end

    book.title = params[:title]
    book.author = author
    book.genre = genre
    book.save
    redirect to "/books/#{book.id}"
  end

  patch '/books/:id/lend' do
    lendee = params[:lendee]
    book = Book.find(params[:id])
    if lendee == ""
      flash[:error] = "You need to enter a lendee"
      redirect to "/books/#{book.id}/lend"
    end

    book.on_loan_to = lendee
    book.save
    redirect to '/books'
  end

  patch '/books/:id/return_book' do
    book = Book.find(params[:id])
    book.on_loan_to = ""
    book.save
    redirect to '/books'
  end
end
