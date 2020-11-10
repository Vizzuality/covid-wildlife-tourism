class PinsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  SERIALIZABLE_ATTRS= %W[id name latitude longitude website type state created_by_id]

  def index
    @pins = Store
      .where.not(latitude: nil)
      .where.not(longitude: nil)

    @pins = @pins.where(state: :live) unless user_signed_in? && current_user.admin?

    # We only send the fields needed to build the UI (no private info)
    serialized_pins = @pins.pluck(SERIALIZABLE_ATTRS).map { |p| SERIALIZABLE_ATTRS.zip(p).to_h }

    # We add whether or not the user is the owner of the pin
    serialized_pins.map! do |pin|
      id = pin.delete('created_by_id')
      state = pin.delete('state')
      pin[:is_owner] = user_signed_in? && id == current_user.id
      pin[:can_edit] = user_signed_in?  && (id == current_user.id || current_user.admin?)
      pin[:public] = state == 'live'
      pin
    end

    respond_to do |format|
      format.json {render json: { :data => serialized_pins }.to_json, status: :ok }
    end
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
    @pin = Store.find(params[:id])

    if pin.created_by_id == current_user.id || current_user.admin?
      # User is editing their own pin or the user is an admin
    else
      # User is reporting an error
    end
  end

  def update
  end

  def destroy
    pin = Store.find(params[:id])

    if pin.created_by_id == current_user.id
      pin.destroy
      redirect_to map_index_path
    end
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
