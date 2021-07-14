class ArrowsController < ApplicationController
  before_action :set_users, only: [:new, :create]
  before_action :authenticate_user!

  def show
    @arrow = Arrow.find(params[:id])
    @author = @arrow.author
  end

  def new
    @arrow = current_user.authored_arrows.build
  end

  def create
    @arrow = current_user.authored_arrows.build(arrow_params)

    if @arrow.save
      redirect_to root_path, notice: 'Great! Your arrow has been successfully sent!'
    else
      render :new
    end
  end

  private

  def set_users
    @users = User.to_select current_user
  end

  def arrow_params
    params.require(:arrow).permit(:owner_id, :description)
  end
end
