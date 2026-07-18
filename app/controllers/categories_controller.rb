# CRUD controller for categories
class CategoriesController < ApplicationController
  requires_feature :feature_expense
  before_action :set_category, only: [ :edit, :update, :destroy ]

  def index
    @categories = current_user.categories
      .left_joins(:expenses)
      .select("categories.*, COUNT(expenses.id) AS expenses_count")
      .group("categories.id")
      .order(:name)
      .page(params[:page]).per(10)
  end

  def new
    @category = current_user.categories.new
  end

  def edit
  end

  def create
    @category = current_user.categories.new(category_params)
    if @category.save
      redirect_to categories_path, notice: t("categories.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: t("categories.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: t("categories.flash.deleted")
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end
end
