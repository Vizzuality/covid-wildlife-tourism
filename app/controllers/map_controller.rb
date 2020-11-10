class MapController < ApplicationController
  skip_before_action :authenticate_user!

  include EnumI18nHelper

  def index
    authorize! :read, :map

    respond_to do |format|
      format.html { render :index }
    end
  end
end
