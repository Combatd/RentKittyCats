class UsersController < ApplicationController
    before_action :already_signed_in

    def new
        user = User.new
        render :new
    end

    def create
        @user = User.new(user_params)
        if user.save
            redirect_to user_url
        else
            flash.new[:errors] = @user.errors.full_messages
            render :new
        end
    end

    private
    def user_params
        params.require(:user).permit(:user_name, :password)
    end
end