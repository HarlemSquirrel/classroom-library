class Helpers
  def self.current_user(session)
    User.find(session[:id]) if session[:id]
  end

  def self.is_logged_in?(session)
    session[:id] != nil && !!self.current_user(session)
  end
end
