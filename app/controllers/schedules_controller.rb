# スケジュールのCRUDコントローラー
class SchedulesController < ApplicationController
  before_action :set_schedule, only: [ :show, :edit, :update, :destroy ]

  def index
    @schedules = current_user.schedules.order(date: :desc, start_time: :asc)

    # キーワード検索（タイトル・メモ）
    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @schedules = @schedules.where("title LIKE ? OR memo LIKE ?", keyword, keyword)
    end

    # 日付検索
    if params[:date].present?
      @schedules = @schedules.where(date: params[:date])
    end
  end

  def show
  end

  def new
    date = params[:date].presence || Date.today
    @schedule = current_user.schedules.new(date: date)
  end

  def edit
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)

    if @schedule.save
      redirect_to @schedule, notice: "スケジュールを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to @schedule, notice: "スケジュールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to schedules_path, notice: "スケジュールを削除しました"
  end

  private

  def set_schedule
    @schedule = current_user.schedules.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(:title, :date, :start_time, :end_time, :memo)
  end
end
