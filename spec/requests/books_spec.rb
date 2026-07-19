require "rails_helper"

RSpec.describe "Books", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated users" do
      get books_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /books" do
    before { sign_in user }

    it "renders the index page" do
      create_list(:book, 3, user: user)
      get books_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /books" do
    before { sign_in user }

    it "creates a reading log with valid params" do
      expect {
        post books_path, params: { book: { title: "テスト書籍", status: "unread" } }
      }.to change(Book, :count).by(1)
    end

    it "does not create a reading log without a title" do
      expect {
        post books_path, params: { book: { title: nil, status: "unread" } }
      }.not_to change(Book, :count)
    end
  end

  describe "PATCH /books/:id" do
    before { sign_in user }

    let!(:book) { create(:book, user: user, status: :unread) }

    it "updates the status" do
      patch book_path(book), params: { book: { status: "reading" } }
      expect(book.reload.status).to eq("reading")
    end
  end

  describe "DELETE /books/:id" do
    before { sign_in user }

    let!(:book) { create(:book, user: user) }

    it "deletes the user's own reading log" do
      expect {
        delete book_path(book)
      }.to change(Book, :count).by(-1)
    end
  end

  describe "search_isbn" do
    before { sign_in user }

    let(:lookup_result) do
      { title: "Sample Book", author: "Author", isbn: "9784798170794", thumbnail: nil, price: "1650" }
    end

    it "returns bibliographic data with the API price via GET" do
      allow(IsbnLookup).to receive(:call).and_return(lookup_result)

      get search_isbn_books_path, params: { isbn: "9784798170794" }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["title"]).to eq("Sample Book")
      expect(body["price"]).to eq("1650")
      expect(body["price_source"]).to eq("api")
    end

    it "prefers the photo price via POST with a camera frame" do
      allow(IsbnLookup).to receive(:call).and_return(lookup_result)
      allow(GeminiPriceReader).to receive(:new).and_return(instance_double(GeminiPriceReader, call: 1760))

      post search_isbn_books_path, params: { isbn: "9784798170794", image: "base64data" }, as: :json

      body = response.parsed_body
      expect(body["price"]).to eq(1760)
      expect(body["price_source"]).to eq("photo")
    end

    it "rejects invalid ISBNs" do
      get search_isbn_books_path, params: { isbn: "123" }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
