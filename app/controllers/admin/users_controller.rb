module Admin
  class UsersController < ApplicationController
    load_and_authorize_resource :admin
    load_resource :user

    layout 'admin'

    # GET /users
    # GET /users.json
    def index
      @users = User.order(:created_at)
        .search(params[:search])
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where(validated: params[:validated]) if params[:validated].present?

      respond_to do |format|
        format.html do
          @users = @users.page(params[:page])
        end
        format.json do
          @users = @users.where(role: :store_owner).limit(25)
        end
      end
    end

    # GET /users/1
    # GET /users/1.json
    def show
      @created_stores = @user.created_stores.search(params[:search])
      @created_stores = @created_stores.by_state(params[:state]) if params[:state].present?
      @created_stores = @created_stores.by_type(params[:type]) if params[:type].present?
      @created_stores = @created_stores.order(:name).page(params[:page])
    end

    # GET /users/new
    def new
      @user = User.new
    end

    # GET /users/1/edit
    def edit; end

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)
      @user.skip_confirmation!

      respond_to do |format|
        if @user.save
          format.html { redirect_to admin_user_path(@user), notice: t('views.admin.users.user_created_successfully') }
        else
          flash.now[:alert] = @user.errors.full_messages
          format.html { render :new }
        end
      end
    end

    # PATCH/PUT /users/1
    # PATCH/PUT /users/1.json
    def update
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to admin_user_path(@user), notice: t('views.admin.users.user_edited_successfully') }
        else
          flash.now[:alert] = @user.errors.full_messages
          format.html { render :edit  }
        end
      end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      query_params = save_query_params
      @user.destroy
      respond_to do |format|
        format.html { redirect_to admin_users_path + query_params, notice: t('views.admin.users.user_deleted_successfully') }
      end
    end

    def approve
      query_params = save_query_params
      action = @user.validated ? 'unapproved' : 'approved'
      @user.revert_validation
      respond_to do |format|
        format.html { redirect_to admin_users_path + query_params, notice: t("views.admin.users.user_#{action.downcase}_successfully") }
      end
    end

    private

    # Only allow a list of trusted parameters through.
    def user_params
      permitted_params = [:name, :email, :password, :password_confirmation]

      permitted_params << :role if current_user.admin?
      permitted_params << {store_ids: []} if current_user.admin?

      params.require(:user).permit(permitted_params)
    end

    def save_query_params
      uri = URI.parse(request.referer)
      uri.query.present? ? '?' + uri.query : ''


    rescue URI::InvalidURIError
      ''
    end
  end
end
