class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @users = User.all
    authorize User
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update(secure_params)
      redirect_to users_path, notice: "User updated."
    else
      redirect_to users_path, alert: "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    authorize user
    user.destroy
    redirect_to users_path, notice: "User deleted."
  end

  def reset_temporary_password
    authorize User
    @back_path = request.referer || client_accounts_path
    user = User.find(params[:id])
    require 'securerandom'
    temp_password = SecureRandom.hex(3)
    user.password = temp_password
    user.password_confirmation = temp_password
    user.confirmed_at = Time.zone.now
    user.temp_password = temp_password
    user.save
    redirect_to @back_path
  end

  private
  def secure_params
    params.require(:user).permit(:role)
  end
end
