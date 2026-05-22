# CRUD controller for reading logs
class BooksController < ApplicationController
  before_action :set_book, only: [ :show, :edit, :update, :destroy ]

  def index
    @books = current_user.books.order(created_at: :desc)

    # Keyword search (title, author, memo)
    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @books = @books.where("title LIKE ? OR author LIKE ? OR memo LIKE ?", keyword, keyword, keyword)
    end

    # Status filter
    if params[:status].present?
      @books = @books.where(status: params[:status])
    end

    @books = @books.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @book = current_user.books.new
  end

  def edit
  end

  def create
    @book = current_user.books.new(book_params)

    if @book.save
      redirect_to @book, notice: t("books.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: t("books.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: t("books.flash.deleted")
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :status, :started_on, :finished_on, :memo, :cover)
  end
end
