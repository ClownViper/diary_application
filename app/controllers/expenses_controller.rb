# CRUD controller for expense entries
class ExpensesController < ApplicationController
  requires_feature :feature_expense
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:index, :new, :edit, :create, :update]

  def index
    @expenses = current_user.expenses.includes(:category)
                            .keyword_search(params[:q])
                            .on_date(params[:date])
                            .order(date: :desc)

    # Category filter
    @expenses = @expenses.where(category_id: params[:category_id]) if params[:category_id].present?

    @expenses = @expenses.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @expense = current_user.expenses.new(date: params[:date].presence || Date.current)
  end

  def edit
  end

  def create
    @expense = current_user.expenses.new(expense_params)
    if @expense.save
      redirect_to @expense, notice: t("expenses.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to @expense, notice: t("expenses.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: t("expenses.flash.deleted")
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
