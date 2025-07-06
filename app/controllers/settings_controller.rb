class SettingsController < ApplicationController
  before_action :require_login

  def show
    @user_setting = current_user.user_setting || current_user.build_user_setting
    @return_namespace = params[:return_namespace]
  end

  def update
    @user_setting = current_user.user_setting || current_user.build_user_setting
    @return_namespace = params[:return_namespace]

    # Generate encryption key if backup is being enabled and no key exists
    if user_setting_params[:backup_enabled] == "1" && @user_setting.encryption_key.blank?
      @user_setting.encryption_key = SecureRandom.base64(32)
    end

    if @user_setting.update(user_setting_params)
      # Return to the namespace user came from
      if @return_namespace.present?
        redirect_to namespace_path(@return_namespace), notice: "Settings updated successfully"
      else
        redirect_to namespaces_path, notice: "Settings updated successfully"
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_setting_params
    params.require(:user_setting).permit(:backup_enabled, :backup_method, :backup_email)
  end
end
