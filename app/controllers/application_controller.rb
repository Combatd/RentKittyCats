class ApplicationController < ActionController::Base
    helper_method :current_user

    private

    def current_user
        if !session[:session_token]
            return nil
        else
            @current_user ||= User.find_by(session_token: session[:session_token])
        end
    end

    def logout_user!
        current_user.reset_session_token!
        session[:session_token] = nil
    end

    def login_user!(user)
        session[:session_token] = user.reset_session_token!
    end

    def already_signed_in
        redirect_to cats_url if current_user
    end
end