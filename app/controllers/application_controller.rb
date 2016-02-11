require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    begin
      Helpers.is_logged_in?(session)
    rescue
      session.clear
    end
    @session = session
    @user = @user = User.find(session[:id])
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

    @authors = Author.all
    @genres = Genre.all
    @session = session
    #binding.pry
    erb :'books/new_book'
  end

  post '/books' do

    redirect to '/books/new' if params[:title] == ""

    if params[:select_author] == "NEW"
      redirect to '/books/new' if params[:new_author] == ""
      author = Author.find_or_create(name: params[:new_author])
    else
      author = Author.find_by(name: params[:select_author])
    end

    if params[:select_genre] == "NEW"
      redirect to '/books/new' if params[:new_genre] == ""
      genre = Genre.find_or_create(name: params[:new_genre])
    else
      genre = Genre.find_by(name: params[:select_genre])
    end
    binding.pry
    book = Book.create(
      title: params[:title],
      author: author,
      genre: genre,
      user: Helpers.current_user(session),
      on_loaned_to: ""
    )

    redirect to "/books/#{book.id}"
  end

  get '/books/:id' do
    redirect to '/login' unless Helpers.is_logged_in?(session)
    @session = session
    @book = Book.find(params[:id])
    @user = User.find(session[:id])
    erb :'books/show_book'
  end
end




class Helpers
  def self.current_user(session)
    User.find(session[:id])
  end

  def self.is_logged_in?(session)
    session[:id] != nil && !!self.current_user(session)
  end
end
