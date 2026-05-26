require "rails_helper"

RSpec.describe "Books", type: :request do
  let(:user) { create(:user) }

  describe "認証" do
    it "未ログインはリダイレクト" do
      get books_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /books" do
    before { sign_in user }

    it "一覧ページが表示される" do
      create_list(:book, 3, user: user)
      get books_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /books" do
    before { sign_in user }

    it "有効なパラメータで読書ログを作成できる" do
      expect {
        post books_path, params: { book: { title: "テスト書籍", status: "unread" } }
      }.to change(Book, :count).by(1)
    end

    it "タイトルがなければ作成できない" do
      expect {
        post books_path, params: { book: { title: nil, status: "unread" } }
      }.not_to change(Book, :count)
    end
  end

  describe "PATCH /books/:id" do
    before { sign_in user }

    let!(:book) { create(:book, user: user, status: :unread) }

    it "ステータスを更新できる" do
      patch book_path(book), params: { book: { status: "reading" } }
      expect(book.reload.status).to eq("reading")
    end
  end

  describe "DELETE /books/:id" do
    before { sign_in user }

    let!(:book) { create(:book, user: user) }

    it "自分の読書ログを削除できる" do
      expect {
        delete book_path(book)
      }.to change(Book, :count).by(-1)
    end
  end
end
