class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @arrows = Arrow.all.where(owner_id: current_user.id).includes(:author)
  end

  def dashboard
    @users = User.all
  end
end
