class ArrowsController < ApplicationController
  before_action :set_users, only: [:new, :create]
  before_action :authenticate_user!

  def show
    @arrow = Arrow.find(params[:id])
  end

  def new
    @arrow = Arrow.new
  end

  def create
    @arrow = Arrow.new(arrow_params)
    @arrow.author_id = current_user.id

    if @arrow.save
      redirect_to root_path, notice: 'Great! Your arrow has been successfully sent!'
    else
      render :new
    end
  end

  private

  def set_users
    @users = User.where.not(id: current_user.id)
  end

  def arrow_params
    params.require(:arrow).permit(:owner_id, :description)
  end
end
