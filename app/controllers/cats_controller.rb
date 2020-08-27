class CatsController < ApplicationController
    before_action :user_owns_cat, only: [:edit, :update]
    
    def index
        @cats = Cat.all
        render :index
    end

    def show
        @cat = Cat.find_by(id: params[:id])

        if @cat
            render :show
        else
            redirect_to cats_url
        end
    end

    def new
        @cat = Cat.new
        render :new
    end

    def create
        @cat = current_user.cats.new(cat_params)
        @cat.user_id = current_user.id
        if @cat.save
            redirect_to cat_url(@cat)
        else
            flash.now[:errors] = @cat.errors.full_messages
            render :new
        end
    end

    def edit
        @cat = Cat.find_by(id: params[:id])
        render :edit
    end

    def update
        @cat = Cat.find(params[:id])
        if @cat.update_attributes(cat_params)
            redirect_to cat_url(@cat)
        else
            flash.now[:errors] = @cat.errors.full_messages
            render :edit
        end
  end

    private
    
    def cat_params
        params.require(:cat).permit(:name, :age, :sex, :birth_date, :color, :description)
    end

    def user_owns_cat
        @cat = Cat.find(params[:id])
        if !current_user
            redirect_to new_session_url
        elsif
            redirect_to cats_url
        else
            render :edit
        end
    end

end