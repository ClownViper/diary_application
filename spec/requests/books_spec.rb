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
end
