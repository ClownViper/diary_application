class HealthRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_health_record, only: [ :show, :edit, :update, :destroy ]

  def index
    @health_records = current_user.health_records.order(date: :desc)

    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @health_records = @health_records.where("memo LIKE ?", keyword)
    end

    if params[:date].present?
      @health_records = @health_records.where(date: params[:date])
    end
  end

  def show
  end

  def new
    date = params[:date].presence || Date.today

    if (existing = current_user.health_records.find_by(date: date))
      redirect_to edit_health_record_path(existing) and return
    end

    @health_record = current_user.health_records.new(date: date)
  end

  def edit
  end

  def create
    date = health_record_params[:date]

    if (existing = current_user.health_records.find_by(date: date))
      redirect_to edit_health_record_path(existing), alert: "この日はすでに記録があります" and return
    end

    @health_record = current_user.health_records.new(health_record_params)

    if @health_record.save
      redirect_to @health_record, notice: "健康記録を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to health_records_path, alert: "この日はすでに記録があります"
  end

  def update
    if @health_record.update(health_record_params)
      redirect_to @health_record, notice: "健康記録を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_record.destroy
    redirect_to health_records_path, notice: "健康記録を削除しました"
  end

  private

  def set_health_record
    @health_record = current_user.health_records.find(params[:id])
  end

  def health_record_params
    params.require(:health_record).permit(:date, :weight, :height, :body_temperature, :systolic_pressure, :diastolic_pressure, :memo)
  end
end
