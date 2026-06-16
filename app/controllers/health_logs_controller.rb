# CRUD controller for health logs
class HealthLogsController < ApplicationController
  requires_feature :feature_health_log
  before_action :set_health_log, only: [ :show, :edit, :update, :destroy ]

  def index
    @health_logs = current_user.health_logs
                               .keyword_search(params[:q])
                               .on_date(params[:date])
                               .order(date: :desc)
                               .page(params[:page]).per(10)
  end

  def stats
    @tab = params[:tab].presence_in(%w[month year]) || "month"

    if @tab == "year"
      # Yearly: all records this year with weight present
      logs = current_user.health_logs
                         .where(date: Date.current.beginning_of_year..Date.current)
                         .where.not(weight: nil)
                         .order(:date)

      # Aggregate into monthly average weights
      grouped = logs.group_by { |l| l.date.strftime("%Y-%m") }
      sorted_keys = grouped.keys.sort
      @chart_labels = sorted_keys.map { |k| "#{k.split('-')[1]}月" }.to_json
      @chart_data   = sorted_keys.map { |k|
        avg = grouped[k].sum(&:weight) / grouped[k].size.to_f
        avg.round(1)
      }.to_json
      @stats_logs = logs
    else
      # Monthly: daily data for the current month
      logs = current_user.health_logs
                         .where(date: Date.current.beginning_of_month..Date.current)
                         .where.not(weight: nil)
                         .order(:date)
      @chart_labels = logs.map { |l| l.date.strftime("%-m/%-d") }.to_json
      @chart_data   = logs.map(&:weight).to_json
      @stats_logs = logs
    end

    # Basic statistics
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
    date = params[:date].presence || Date.current
    return if redirect_to_existing_health_log(date)

    @health_log = current_user.health_logs.new(date: date)
  end

  def edit
  end

  def create
    date = health_log_params[:date]
    return if redirect_to_existing_health_log(date, alert: t("health_logs.flash.existing_date"))

    @health_log = current_user.health_logs.new(health_log_params)

    if @health_log.save
      redirect_to @health_log, notice: t("health_logs.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to health_logs_path, alert: t("health_logs.flash.existing_date")
  end

  def update
    if @health_log.update(health_log_params)
      redirect_to @health_log, notice: t("health_logs.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_log.destroy
    redirect_to health_logs_path, notice: t("health_logs.flash.deleted")
  end

  private

  def set_health_log
    @health_log = current_user.health_logs.find(params[:id])
  end

  def health_log_params
    params.require(:health_log).permit(:date, :weight, :condition, :sleep_hours, :temperature, :memo)
  end

  # Redirects to the edit page if a health log already exists for the given date; returns true
  def redirect_to_existing_health_log(date, alert: nil)
    existing = current_user.health_logs.find_by(date: date)
    return false unless existing

    redirect_to edit_health_log_path(existing), alert: alert
    true
  end
end
