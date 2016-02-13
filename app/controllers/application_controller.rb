require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    register Sinatra::Flash
    set :session_secret, "secret"
  end

  get '/' do
    begin
      Helpers.is_logged_in?(session)
    rescue
      session.clear
    end
    @session = session
    @user = Helpers.current_user(session)
    erb :index
  end

  ################### users ###################
  get '/signup' do
    redirect to '/' if Helpers.is_logged_in?(session)
    @session = session
    erb :'users/create_user'
  end

  post '/signup' do
    if params[:username] == "" || params[:email] == "" || params[:password] == ""
      flash[:error] = "All fields must be completed"
      redirect to '/signup'
    end

    if !!User.find_by(username: params[:username])
      flash[:error] = "There is already an account with this username"
      redirect to '/signup'
    elsif !!User.find_by(email: params[:email])
      flash[:error] = "There is already an account with this email"
      redirect to '/signup'
    end
    # create new user
    user = User.new(
      username: params[:username],
      email: params[:email],
      password: params[:password]
    )

    if user.save
      session[:id] = user.id
      redirect '/'
    else
      flash[:error] = "Something went wrong. Please try again."
      redirect '/signup'
    end
  end

  get '/login' do
    redirect to '/' if Helpers.is_logged_in?(session)
    @session = session
    erb :'users/login'
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
        session[:id] = user.id
        redirect '/'
    else
      flash[:error] = "Your username or password is incorrect"
      redirect '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end


  ########################## books #######################
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
    #binding.pry
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
