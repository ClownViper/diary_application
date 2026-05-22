class CalendarController < ApplicationController
  before_action :authenticate_user!

  def index
    # 表示する月
    @date = params[:date] ? Date.parse(params[:date]) : Date.today

    # 月の開始・終了
    @start_date = @date.beginning_of_month
    @end_date   = @date.end_of_month

    # データ取得
    diaries = current_user.diaries.where(date: @start_date..@end_date)
    expenses = current_user.expenses.where(date: @start_date..@end_date)
    health_logs = current_user.health_logs.where(date: @start_date..@end_date)
    schedules = current_user.schedules.where(date: @start_date..@end_date)

    # 日付ごとにまとめる（ビューで高速に参照できるように）
    @diaries_by_date = diaries.index_by(&:date)
    @expenses_by_date = expenses.group_by(&:date)
    @health_logs_by_date = health_logs.index_by(&:date)
    @schedules_by_date = schedules.group_by(&:date)
  end

  def layer
    @date = Date.parse(params[:date])
    @diary = Diary.find_by(date: @date, user: current_user)
    @expenses = Expense.where(date: @date, user: current_user)
    @health_log = HealthLog.find_by(date: @date, user: current_user)
    @schedules = Schedule.where(date: @date, user: current_user).order(start_time: :asc)

    render partial: "calendar/layer"
  end
end
