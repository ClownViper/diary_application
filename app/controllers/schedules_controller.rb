# CRUD controller for schedules
class SchedulesController < ApplicationController
  requires_feature :feature_schedule
  before_action :set_schedule, only: [ :show, :edit, :update, :destroy ]

  def index
    @schedules = current_user.schedules
                             .keyword_search(params[:q])
                             .on_date(params[:date])
                             .order(date: :desc, start_time: :asc)
                             .page(params[:page]).per(10)
  end

  def show
  end

  def new
    date = params[:date].presence || Date.current
    @schedule = current_user.schedules.new(date: date)
  end

  def edit
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)

    if @schedule.save
      redirect_to @schedule, notice: t("schedules.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to @schedule, notice: t("schedules.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to schedules_path, notice: t("schedules.flash.deleted")
  end

  private

  def set_schedule
    @schedule = current_user.schedules.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(:title, :date, :start_time, :end_time, :memo)
  end
end
