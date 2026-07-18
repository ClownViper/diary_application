# Controller for the dashboard (overview) page
class DashboardController < ApplicationController
  def index
    @today = Date.current

    # Today's diary and expenses for the current user
    @today_diary = current_user.diaries.find_by(date: @today)
    @today_expenses = current_user.expenses.where(date: @today)

    # This month's expenses for the current user
    @monthly_expenses = current_user.expenses.where(date: @today.all_month)
    @monthly_total = @monthly_expenses.sum(:amount)

    # Monthly budget target from content settings
    @expense_target = current_user.expense_target

    # Recent records for the current user
    @recent_diaries = current_user.diaries.order(date: :desc).limit(3)
    @recent_expenses = current_user.expenses.includes(:category).order(date: :desc).limit(3)

    # Health log
    @today_health_log = current_user.health_logs.find_by(date: @today)
    @recent_health_logs = current_user.health_logs.order(date: :desc).limit(3)

    # Weight data for sparkline chart (last 30 days, weight present)
    recent_weight_logs = current_user.health_logs
                                     .where(date: 30.days.ago.to_date..@today)
                                     .where.not(weight: nil)
                                     .order(:date)
    @sparkline_labels = recent_weight_logs.map { |l| l.date.strftime("%-m/%-d") }.to_json
    @sparkline_data   = recent_weight_logs.map(&:weight).to_json
    @sparkline_any    = recent_weight_logs.any?

    # Today's schedules
    @today_schedules = current_user.schedules.where(date: @today).order(start_time: :asc)

    # Books currently being read
    @reading_books = current_user.books.reading.limit(3)

    # Mini calendar data
    @first_day = @today.beginning_of_month
    @last_day  = @today.end_of_month
    @days = (@first_day..@last_day).to_a
  end
end
