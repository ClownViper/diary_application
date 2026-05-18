class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: [:show, :edit, :update, :destroy]

  def index
    @diaries = current_user.diaries.order(date: :desc)

    # キーワード検索
    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @diaries = @diaries.where("title LIKE ? OR body LIKE ?", keyword, keyword)
    end

    # 日付検索
    if params[:date].present?
      @diaries = @diaries.where(date: params[:date])
    end
  end

  def show
  end

  def new
    date = params[:date].presence || Date.today

    # 既にその日の日記があるなら編集へ
    if (existing = current_user.diaries.find_by(date: date))
      redirect_to edit_diary_path(existing) and return
    end

    @diary = current_user.diaries.new(date: date)
  end

  def edit
  end

  def create
    date = diary_params[:date]

    # 既にその日の日記があるなら編集へ
    if (existing = current_user.diaries.find_by(date: date))
      redirect_to edit_diary_path(existing), alert: "この日はすでに日記があります" and return
    end

    @diary = current_user.diaries.new(diary_params)

    if @diary.save
      redirect_to @diary, notice: "日記を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to diaries_path, alert: "この日はすでに日記があります"
  end

  def update
    if @diary.update(diary_params)
      redirect_to @diary, notice: "日記を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diary.destroy
    redirect_to diaries_path, notice: "日記を削除しました"
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def diary_params
    params.require(:diary).permit(:title, :body, :date, :image)
  end
end
