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
  # Tries OpenBD first (free, no key), then falls back to Google Books (requires API key)
  def search_isbn
    require "net/http"
    isbn = params[:isbn].to_s.gsub(/[^0-9X]/i, "")
    return render json: { error: t("books.scanner.invalid_isbn") }, status: :bad_request if isbn.length < 10

    result = search_openbd(isbn) || search_google_books(isbn)

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

  # OpenBD: Japanese book database (free, no API key required)
  def search_openbd(isbn)
    uri = URI("https://api.openbd.jp/v1/get?isbn=#{isbn}")
    res = Net::HTTP.get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)

    data = JSON.parse(res.body)
    return nil if data.blank? || data[0].nil?

    summary = data[0]["summary"]
    return nil if summary.blank? || summary["title"].blank?

    {
      title:     summary["title"],
      author:    summary["author"].presence,
      thumbnail: summary["cover"].presence
    }
  end

  # Google Books: international fallback (API key optional but recommended)
  def search_google_books(isbn)
    uri = URI("https://www.googleapis.com/books/v1/volumes")
    params = { q: "isbn:#{isbn}" }
    api_key = Rails.application.credentials.dig(:google_books, :api_key)
    params[:key] = api_key if api_key.present?
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)

    data = JSON.parse(res.body)
    return nil if data["totalItems"].to_i == 0

    info      = data["items"][0]["volumeInfo"]
    thumbnail = info.dig("imageLinks", "thumbnail")&.sub("http://", "https://")

    {
      title:     info["title"],
      author:    info["authors"]&.join(", "),
      thumbnail: thumbnail
    }
  end

  def book_params
    params.require(:book).permit(:title, :author, :status, :started_on, :finished_on, :memo, :cover)
  end
end
