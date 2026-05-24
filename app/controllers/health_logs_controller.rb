# 体重・体調ログのCRUDコントローラー
class HealthLogsController < ApplicationController
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

    @health_logs = @health_logs.page(params[:page]).per(10)
  end

  def stats
    @tab = params[:tab].presence_in(%w[month year]) || "month"

    if @tab == "year"
      # 年内：今年の全記録（体重あるもの）
      logs = current_user.health_logs
                         .where(date: Date.today.beginning_of_year..Date.today)
                         .where.not(weight: nil)
                         .order(:date)

      # 月ごとの平均体重に集約
      grouped = logs.group_by { |l| l.date.strftime("%Y-%m") }
      sorted_keys = grouped.keys.sort
      @chart_labels = sorted_keys.map { |k| "#{k.split('-')[1]}月" }.to_json
      @chart_data   = sorted_keys.map { |k|
        avg = grouped[k].sum(&:weight) / grouped[k].size.to_f
        avg.round(1)
      }.to_json
      @stats_logs = logs
    else
      # 月内：今月の日次データ
      logs = current_user.health_logs
                         .where(date: Date.today.beginning_of_month..Date.today)
                         .where.not(weight: nil)
                         .order(:date)
      @chart_labels = logs.map { |l| l.date.strftime("%-m/%-d") }.to_json
      @chart_data   = logs.map(&:weight).to_json
      @stats_logs = logs
    end

    # 簡易統計
    weights = @stats_logs.map(&:weight)
    if weights.any?
      @weight_avg = (weights.sum / weights.size.to_f).round(1)
      @weight_max = weights.max
      @weight_min = weights.min
    end
  end

  def show
  end

  def new
    date = params[:date].presence || Date.today
    return if redirect_to_existing_health_log(date)

    @health_log = current_user.health_logs.new(date: date)
  end

  def edit
  end

  def create
    date = health_log_params[:date]
    return if redirect_to_existing_health_log(date, alert: "この日はすでに記録があります")

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

  # その日の体調ログが既にあれば編集画面へリダイレクトし true を返す
  def redirect_to_existing_health_log(date, alert: nil)
    existing = current_user.health_logs.find_by(date: date)
    return false unless existing

    redirect_to edit_health_log_path(existing), alert: alert
    true
  end
end
