# CRUD controller for reading logs (includes ISBN lookup via Google Books API)
class BooksController < ApplicationController
  before_action :set_book, only: [ :show, :edit, :update, :destroy ]

  def index
    @books = current_user.books
                         .keyword_search(params[:q])
                         .order(created_at: :desc)

    # Status filter
    @books = @books.where(status: params[:status]) if params[:status].present?

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

  # GET /books/search_isbn?isbn=9784xxx
  def search_isbn
    isbn = params[:isbn].to_s.gsub(/[^0-9X]/i, "")
    return render json: { error: t("books.scanner.invalid_isbn") }, status: :bad_request if isbn.length < 10

    result = IsbnLookup.call(isbn)

    if result
      render json: result
    else
      render json: { error: t("books.scanner.not_found") }, status: :not_found
    end
  rescue => e
    Rails.logger.error("ISBN search error: #{e.message}")
    render json: { error: t("books.scanner.api_error") }, status: :internal_server_error
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :status, :started_on, :finished_on, :memo, :cover)
  end
end
