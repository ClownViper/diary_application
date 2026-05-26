require "rails_helper"

RSpec.describe "Expenses", type: :request do
  let(:user) { create(:user) }

  describe "認証" do
    it "未ログインはリダイレクト" do
      get expenses_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /expenses" do
    before { sign_in user }

    it "一覧ページが表示される" do
      create_list(:expense, 3, user: user)
      get expenses_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /expenses" do
    before { sign_in user }

    it "有効なパラメータで出費を作成できる" do
      expect {
        post expenses_path, params: { expense: { name: "ランチ", amount: 800, date: Date.today } }
      }.to change(Expense, :count).by(1)
    end

    it "金額が0では作成できない" do
      expect {
        post expenses_path, params: { expense: { name: "テスト", amount: 0, date: Date.today } }
      }.not_to change(Expense, :count)
    end
  end

  describe "DELETE /expenses/:id" do
    before { sign_in user }

    let!(:expense) { create(:expense, user: user) }

    it "自分の出費を削除できる" do
      expect {
        delete expense_path(expense)
      }.to change(Expense, :count).by(-1)
    end
  end
end
