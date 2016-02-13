class UsersController < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    register Sinatra::ActiveRecordExtension
    register Sinatra::Flash
    set :session_secret, "secret"
  end

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
end
