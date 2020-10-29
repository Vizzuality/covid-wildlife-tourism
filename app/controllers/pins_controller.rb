class PinsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def create
    if (params[:store].nil?)
      flash[:alert] = t 'views.pins.select_type_error'
      redirect_to new_pin_path
    else
      redirect_to map_index_path pin_params.merge(action: 'location')
    end
  end

  def new
    @pin = Store.new
  end

  def edit
  end

  def update
  end

  def pin_params
    permitted_params = [:store_type]

    params.require(:store).permit(permitted_params)
  end
end
