# CRUD controller for diary entries
class DiariesController < ApplicationController
  requires_feature :feature_diary
  before_action :set_diary, only: [ :show, :edit, :update, :destroy ]

  def index
    @diaries = current_user.diaries
                           .with_attached_image
                           .keyword_search(params[:q])
                           .on_date(params[:date])
                           .order(date: :desc)
                           .page(params[:page]).per(10)
  end

  def show
  end

  def new
    date = params[:date].presence || Date.current
    @existing_diary = current_user.diaries.find_by(date: date)
    @diary = current_user.diaries.new(date: date)
  end

  def edit
  end

  def create
    date = diary_params[:date]
    return if redirect_to_existing_diary(date, alert: t("diaries.flash.existing_date"))

    @diary = current_user.diaries.new(diary_params)

    if @diary.save
      redirect_to @diary, notice: t("diaries.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to diaries_path, alert: t("diaries.flash.existing_date")
  end

  def update
    if @diary.update(diary_params)
      redirect_to @diary, notice: t("diaries.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diary.destroy
    redirect_to diaries_path, notice: t("diaries.flash.deleted")
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def diary_params
    params.require(:diary).permit(:title, :body, :date, :image)
  end

  # Redirects to the edit page if a diary already exists for the given date; returns true
  def redirect_to_existing_diary(date, alert: nil)
    existing = current_user.diaries.find_by(date: date)
    return false unless existing

    redirect_to edit_diary_path(existing), alert: alert
    true
  end
end
