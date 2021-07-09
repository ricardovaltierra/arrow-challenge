class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @arrows = Arrow.find_by(owner_id: current_user.id)
  end

  def dashboard
    @users = User.all
  end
end
