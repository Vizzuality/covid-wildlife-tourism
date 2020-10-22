class MapController < ApplicationController
  skip_before_action :authenticate_user!

  include EnumI18nHelper

  # GET /stores
  # GET /stores.json
  def index
    authorize! :read, :map

    # @bounds = if params[:coordinates].present?
    #             params[:coordinates].map { |s| s.split(',').map(&:to_f) }
    #           else
    #             default_bounds
    #           end

    # @shops = Store.where.not(latitude: nil).where.not(longitude: nil)
    #   .where.not(state: :archived).in_bounding_box(@bounds)

    # if current_user.store_owner?
    #   @shops = @shops.where(id: current_user.user_stores.where(approved: true).pluck(:store_id))
    # end

    # @shops = @shops.index_by(&:id)

    respond_to do |format|
      format.html { render :index }
      # format.json { render json: @shops, status: :ok }
    end
  end

  # POST /map
  def create
    @shop = Store.new(map_params)
    authorize! :create, @shop

    @shop.managers << current_user if current_user.store_owner?
    @shop.source = 'Community' if current_user.contributor?

    respond_to do |format|
      if @shop.save
        format.json { render json: @shop, status: :created, location: @shop }
      else
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
    # TODO: mark as to validate
  end

  def update
    # PUT /map/:id?name=myname
    @shop = Store.find(params[:id])
    authorize! :update, @shop

    @shop.attributes = map_params

    respond_to do |format|
      if @shop.save
        format.json { render json: @shop, status: :ok, location: @shop }
      else
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @shop = Store.find(params[:id])
    @shop.state = 3

    respond_to do |format|
      if @shop.save
        format.json { render json: @shop, status: :ok, location: @shop }
      else
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # private

#   def map_params
#     params.permit(:name, :group, :street, :city,
#                   :zip_code, :country, :district, :store_type,
#                   :latitude, :longitude, :capacity, :details, :coordinates)
#   end

#   def default_bounds
#     bounds = {
#       'pt' => [
#         [-8.693305501609501, 41.11531424472605],
#         [-8.520026252042584, 41.17823491872437]
#       ],
#       'es' => [
#         [-3.941566736714776, 40.328785315750025],
#         [-3.4482048268615415, 40.515118259540344]
#       ],
#       'sk' => [
#         [16.641476790705553, 47.6684309174384],
#         [22.732738732476804, 49.66387636689515]
#       ]
#     }
#     bounds.fetch(I18n.locale.to_s) { bounds['pt'] }
#   end
end
