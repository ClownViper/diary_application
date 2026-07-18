# Controller for the monthly calendar view
class CalendarController < ApplicationController
  def index
    # Month to display
    @date = parse_date(params[:date])

    # Start and end of the month
    @start_date = @date.beginning_of_month
    @end_date   = @date.end_of_month

    # Fetch records
    diaries = current_user.diaries.where(date: @start_date..@end_date)
    expenses = current_user.expenses.where(date: @start_date..@end_date)
    health_logs = current_user.health_logs.where(date: @start_date..@end_date)
    schedules = current_user.schedules.where(date: @start_date..@end_date)

    # Group by date for fast lookup in views
    @diaries_by_date = diaries.index_by(&:date)
    @expenses_by_date = expenses.group_by(&:date)
    @health_logs_by_date = health_logs.index_by(&:date)
    @schedules_by_date = schedules.group_by(&:date)
  end

  def layer
    @date = parse_date(params[:date])
    @diary      = current_user.diaries.find_by(date: @date)
    @expenses   = current_user.expenses.includes(:category).where(date: @date)
    @health_log = current_user.health_logs.find_by(date: @date)
    @schedules  = current_user.schedules.where(date: @date).by_start_time

    render partial: "calendar/layer"
  end

  private

  # Parse a date param, falling back to today on missing/invalid input
  def parse_date(value)
    value.present? ? Date.parse(value) : Date.current
  rescue ArgumentError, TypeError
    Date.current
  end
end
