class StatsController < ApplicationController
  def index
    authorize! :read, :stats
    @users_per_day = ::Api::Charts::Home.new.users_per_day
  end
end
