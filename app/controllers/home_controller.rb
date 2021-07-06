class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def show
  end

  def dashboard
  end
end
