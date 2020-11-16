module Admin
  class StoresController < AdminController
    load_and_authorize_resource :store
    before_action :set_stores, only: [:index, :approve_all]

    layout 'admin'

    # GET /stores
    # GET /stores.json
    def index
      @stores = @stores.full_text_search(params[:search]).with_pg_search_rank if params[:search].present?
      @stores = @stores.by_state(params[:state]) if params[:state].present?
      @stores = @stores.by_type(params[:type]) if params[:type].present?
      @stores = @stores.where(latitude: nil).or(Store.where(longitude: nil)) if params[:no_info]

      @stores = @stores.order(:name)

      respond_to do |format|
        format.html do
          @stores = @stores.page(params[:page])
        end
        format.json do
          @stores = @stores.limit(50)
        end
        format.csv do
          send_data @stores.to_csv, type: 'csv', filename: 'stores-export.csv'
        end
      end
    end

    # GET /stores/1
    # GET /stores/1.json
    def show
      if (@store.related_store_id)
        @related_store = Store.find(@store.related_store_id)
      end
    end

    # GET /stores/new
    def new
      @store = Store.new
    end

    # GET /stores/1/edit
    def edit; end

    # PATCH/PUT /stores/1
    # PATCH/PUT /stores/1.json
    def update
      respond_to do |format|
        if @store.update(store_params)
          format.html { redirect_to admin_pin_path(@store), notice: t('views.admin.stores.pin_edited_successfully') }
        else
          flash.now[:alert] = @store.errors.full_messages
          format.html { render :edit }
        end
      end
    end

    # DELETE /stores/1
    # DELETE /stores/1.json
    def destroy
      query_params = save_query_params
      @store.destroy
      respond_to do |format|
        format.html do
          redirect_to admin_pins_path + query_params, notice: t('views.admin.stores.pin_deleted_successfully')
        end
        format.json { head :no_content }
      end
    end

    def approve
      query_params = save_query_params
      @store = Store.find(params[:id])

      if @store.approve
        redirect_to admin_pins_path + query_params, notice: t('views.admin.stores.pin_approved_successfully')
      else
        redirect_to admin_pins_path + query_params, notice:t('views.admin.stores.pin_approved_unsuccessfully')
      end
    end

    private

    def set_stores
      @stores = Store.all
    end

    # Only allow a list of trusted parameters through.
    def store_params
      permitted_params = [:name, :latitude, :longitude, :municipality,
                          :type, :state]

      if params[:community].present?
        params.require(:community).permit(permitted_params)
      elsif params[:enterprise].present?
        params.require(:enterprise).permit(permitted_params)
      else
        params.require(:store).permit(permitted_params)
      end
    end

    def search_params
      {
        state: params[:state],
        search: params[:search],
        type: params[:type]
      }
    end

    def save_query_params
      uri = URI.parse(request.referer)
      uri.query.present? ? '?' + uri.query : ''


    rescue URI::InvalidURIError
      ''
    end
  end
end
