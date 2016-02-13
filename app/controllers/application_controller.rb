require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    register Sinatra::ActiveRecordExtension
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
end
