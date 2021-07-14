class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @arrows = Arrow.arrows_with_author current_user
  end

  def dashboard
    @users = User.all
  end
end
