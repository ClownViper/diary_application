class DashboardController < ApplicationController

  def index
    @today = Date.today

    # 今日の日記・出費（ユーザー限定）
    @today_diary = current_user.diaries.find_by(date: @today)
    @today_expenses = current_user.expenses.where(date: @today)

    # 今月の出費（ユーザー限定）
    @monthly_expenses = current_user.expenses.where(date: @today.all_month)
    @monthly_total = @monthly_expenses.sum(:amount)

    # 出費目安金額（コンテンツ設定から取得）
    @expense_target = current_user.expense_target

    # 最近のデータ（ユーザー限定）
    @recent_diaries = current_user.diaries.order(date: :desc).limit(3)
    @recent_expenses = current_user.expenses.order(date: :desc).limit(3)

    # 体調ログ
    @today_health_log = current_user.health_logs.find_by(date: @today)
    @recent_health_logs = current_user.health_logs.order(date: :desc).limit(3)

    # 体重スパークライン用（直近30日・体重あるもの）
    recent_weight_logs = current_user.health_logs
                                     .where(date: 30.days.ago.to_date..@today)
                                     .where.not(weight: nil)
                                     .order(:date)
    @sparkline_labels = recent_weight_logs.map { |l| l.date.strftime("%-m/%-d") }.to_json
    @sparkline_data   = recent_weight_logs.map(&:weight).to_json
    @sparkline_any    = recent_weight_logs.any?

    # 今日のスケジュール
    @today_schedules = current_user.schedules.where(date: @today).order(start_time: :asc)

    # 読書中の本
    @reading_books = current_user.books.reading.limit(3)

    # ミニカレンダー用
    @first_day = @today.beginning_of_month
    @last_day  = @today.end_of_month
    @days = (@first_day..@last_day).to_a
  end
end
