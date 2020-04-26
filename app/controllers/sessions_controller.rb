class SessionsController < ApplicationController
    def new
        render :new
    end

    def create
        user = User.find_by_credentials(params[:user][:user_name], params[:user][:password])

        if !user
            flash.now[:errors] = ["Wrong username or password entered"]
            render :new
        else
            login_user!(user)
            redirect_to cats_url
        end
    end

    def destroy
        logout_user!
        redirect_to new_session_url
    end
end