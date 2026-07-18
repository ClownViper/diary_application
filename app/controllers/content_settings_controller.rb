# Controller for content feature settings

class ContentSettingsController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(content_settings_params)
      redirect_to content_settings_path, notice: t("content_settings.flash.updated")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  # Strong parameters for content settings
  def content_settings_params
    params.require(:user).permit(
      :feature_diary, :feature_expense, :feature_health_log,
      :feature_book, :feature_schedule, :expense_target
    )
  end
end
