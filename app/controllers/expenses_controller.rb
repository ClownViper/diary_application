class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:index, :new, :edit, :create, :update]

  def index
    @expenses = current_user.expenses.includes(:category).order(date: :desc)

    # キーワード検索（名前・メモ）
    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @expenses = @expenses.where("name LIKE ? OR memo LIKE ?", keyword, keyword)
    end

    # 日付検索
    if params[:date].present?
      @expenses = @expenses.where(date: params[:date])
    end

    # カテゴリ検索
    if params[:category_id].present?
      @expenses = @expenses.where(category_id: params[:category_id])
    end
  end

  def show
  end

  def new
    @expense = current_user.expenses.new(date: params[:date].presence || Date.today)
  end

  def edit
  end

  def create
    @expense = current_user.expenses.new(expense_params)
    if @expense.save
      redirect_to @expense, notice: "出費を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to @expense, notice: "出費を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: "出費を削除しました"
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def set_categories
    @categories = current_user.categories.order(:name)
  end

  def expense_params
    params.require(:expense).permit(:name, :amount, :date, :memo, :category_id)
  end
end
