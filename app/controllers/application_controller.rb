require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    @session = session
    erb :index
  end

  ################### users ###################
  get '/signup' do
    redirect to '/' if Helpers.is_logged_in?(session)
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
    #binding.pry
    if user.save
      session[:id] = user.id
      redirect '/'
    else
      redirect '/signup'
    end
  end

  get '/login' do
    redirect to '/' if Helpers.is_logged_in?(session)
    erb :'users/login'
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
        session[:id] = user.id
        #binding.pry
        redirect '/'
    else
        redirect '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
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
