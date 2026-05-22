# コンテンツ設定コントローラー
# 各機能のON/OFFと出費目安金額を管理
class ContentSettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(content_settings_params)
      redirect_to content_settings_path, notice: "コンテンツ設定を更新しました。"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  # コンテンツ設定のストロングパラメータ
  def content_settings_params
    params.require(:user).permit(
      :feature_diary, :feature_expense, :feature_health_log,
      :feature_book, :feature_schedule, :expense_target
    )
  end
end
