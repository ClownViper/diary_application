class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @today = Date.today

    # 今日の日記・出費（ユーザー限定）
    @today_diary = current_user.diaries.find_by(date: @today)
    @today_expenses = current_user.expenses.where(date: @today)

    # 今月の出費（ユーザー限定）
    @monthly_expenses = current_user.expenses.where(date: @today.all_month)
    @monthly_total = @monthly_expenses.sum(:amount)

    # 最近のデータ（ユーザー限定）
    @recent_diaries = current_user.diaries.order(date: :desc).limit(3)
    @recent_expenses = current_user.expenses.order(date: :desc).limit(3)

    # ミニカレンダー用
    @first_day = @today.beginning_of_month
    @last_day  = @today.end_of_month
    @days = (@first_day..@last_day).to_a
  end
end
