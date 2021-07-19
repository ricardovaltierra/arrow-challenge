# frozen_string_literal: true

class ArrowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_users, only: [:new, :create]

  def show
    @arrow = Arrow.find(params[:id])
  end

  def new
    @arrow = current_user.authored_arrows.build
  end

  def create
    @arrow = current_user.authored_arrows.build(arrow_params)

    respond_to do |format|
      if @arrow.save
        format.html { redirect_to root_path, notice: 'Great! Your arrow has been successfully sent!' }
      else
        format.turbo_stream
        format.html { render :new }
      end
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
