class PinsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def create
    if (pin_params[:type].blank?)
      flash[:alert] = t 'views.pins.select_type_error'
      redirect_to new_pin_path
    elsif (!pin_params[:latitude].blank? && !pin_params[:longitude].blank?)
      @pin = Store.new pin_params
      if (@pin.save)
        redirect_to map_index_path(pin: @pin.id)
      else
        flash.now[:alert] = @pin.errors.full_messages
        render :new
      end
    else
      redirect_to map_index_path(operation: 'location', next: new_pin_path(pin_params))
    end
  end

  def new
    @pin = Store.new

    if (params[:type] == 'Community')
      @pin.type = 'Community'
      @pin.latitude = params[:lat]
      @pin.longitude = params[:lon]
    elsif (params[:type] == 'Enterprise')
      @pin.type = 'Enterprise'
      @pin.latitude = params[:lat]
      @pin.longitude = params[:lon]
    end
  end

  def edit
  end

  def update
  end

  def pin_params
    permitted_params = [
      :type,
      :name,
      :website,
      :latitude,
      :longitude,
      :population_size,
      :user_is_owner,
      :owner_details,
      :farming_reliance,
      :wildlife_reliance,
      :enterprise_type,
      :ownership
    ]

    if params[:community].present?
      params.require(:community).permit(permitted_params)
    elsif params[:enterprise].present?
      params.require(:enterprise).permit(permitted_params)
    else
      params.require(:store).permit(permitted_params)
    end
  end
end
