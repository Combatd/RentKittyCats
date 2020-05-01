class CatRentalRequestsController < ApplicationController
    before_action :only_owner, only: [:approve, :deny]
    
    def new
        @rental_request = CatRentalRequest.new
    end
    
    def create
        @rental_request = CatRentalRequest.new(cat_rental_request_params)
        @rental_request.user_id = current_user.id

        if @rental_request.save
            redirect_to cat_url(@rental_request.cat)
        else
            flash.now[:errors] = @rental_request.errors.full_messages
            render :new
        end
    end

    def approve
        current_cat_rental_request.approve!
        redirect_to cat_url(current_cat)
    end

    def deny
        current_cat_rental_request.deny!
        redirect_to cat_url(current_cat)
    end

    private
    def cat_rental_request_params
        params.require(:cat_rental_request).permit(:cat_id, :start_date, :end_date, :status)
    end

    def current_cat
        current_cat_rental_request.cat
    end

    def current_cat_rental_request
        @rental_request ||= CatRentalRequest.includes(:cat).find(params[:id])
    end

    def only_owner
        if current_cat.owner != current_user
            redirect_to cat_url(current_cat.id)
        end
    end

end