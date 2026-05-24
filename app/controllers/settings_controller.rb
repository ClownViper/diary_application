# 通知設定コントローラー
class SettingsController < ApplicationController

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(settings_params)
      redirect_to settings_path, notice: "通知設定を更新しました"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:user).permit(
      :notify_diary, :notify_diary_time,
      :notify_entry, :notify_entry_time,
      :notify_health, :notify_health_time,
      :notify_books, :notify_books_time,
      :notify_schedule, :notify_schedule_before
    )
  end
end
