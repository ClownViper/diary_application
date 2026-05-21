# 体重・体調ログのCRUDコントローラー
class HealthLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_health_log, only: [ :show, :edit, :update, :destroy ]

  def index
    @health_logs = current_user.health_logs.order(date: :desc)

    # キーワード検索（メモ）
    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @health_logs = @health_logs.where("memo LIKE ?", keyword)
    end

    # 日付検索
    if params[:date].present?
      @health_logs = @health_logs.where(date: params[:date])
    end
  end

  def show
  end

  def new
    date = params[:date].presence || Date.today

    # 既にその日の記録があるなら編集へ
    if (existing = current_user.health_logs.find_by(date: date))
      redirect_to edit_health_log_path(existing) and return
    end

    @health_log = current_user.health_logs.new(date: date)
  end

  def edit
  end

  def create
    date = health_log_params[:date]

    # 既にその日の記録があるなら編集へ
    if (existing = current_user.health_logs.find_by(date: date))
      redirect_to edit_health_log_path(existing), alert: "この日はすでに記録があります" and return
    end

    @health_log = current_user.health_logs.new(health_log_params)

    if @health_log.save
      redirect_to @health_log, notice: "体調ログを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to health_logs_path, alert: "この日はすでに記録があります"
  end

  def update
    if @health_log.update(health_log_params)
      redirect_to @health_log, notice: "体調ログを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_log.destroy
    redirect_to health_logs_path, notice: "体調ログを削除しました"
  end

  private

  def set_health_log
    @health_log = current_user.health_logs.find(params[:id])
  end

  def health_log_params
    params.require(:health_log).permit(:date, :weight, :condition, :memo)
  end
end
