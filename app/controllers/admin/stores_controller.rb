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
    def show; end

    # GET /stores/new
    def new
      @store = Store.new
    end

    # GET /stores/1/edit
    def edit; end

    def edit_schedule
      @week_days = if @store.week_days.any?
                    @store.week_days.order(:day)
                  else
                    Date::DAYNAMES.map do |i|
                      @store.week_days.build(day: i.downcase.to_sym)
                    end
                  end
    end

    # PATCH/PUT /stores/1
    # PATCH/PUT /stores/1.json
    def update
      respond_to do |format|
        if @store.update(store_params)
          format.html { redirect_to admin_store_path(@store), notice: 'Store was successfully updated.' }
          format.json { render :show, status: :ok, location: @store }
        else
          format.html { render :edit }
          format.json { render json: @store.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /stores/1
    # DELETE /stores/1.json
    def destroy
      @store.destroy
      respond_to do |format|
        format.html do
          redirect_to polymorphic_url(controller_name, search_params),
                      notice: 'Store was successfully destroyed.'
        end
        format.json { head :no_content }
      end
    end

    def approve_all
      @stores = @stores.search(params[:search])
      @stores = @stores.by_type(params[:type]) if params[:type].present?
      size = @stores.size
      @stores.update_all(state: :live) # rubocop:disable Rails/SkipsModelValidations

      respond_to do |format|
        format.html do
          redirect_to polymorphic_url(controller_name),
                      notice: t('controllers.stores.approve_all.notice', size: size)
        end
        format.json { head :no_content }
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
  end
end
