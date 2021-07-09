class ArrowController < ApplicationController
  before_action :authenticate_user!

  def new
    @arrow = Arrow.new
  end
end
