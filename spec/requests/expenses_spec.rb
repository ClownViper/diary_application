require "rails_helper"

RSpec.describe "Expenses", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated users" do
      get expenses_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /expenses" do
    before { sign_in user }

    it "renders the index page" do
      create_list(:expense, 3, user: user)
      get expenses_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /expenses" do
    before { sign_in user }

    it "creates an expense with valid params" do
      expect {
        post expenses_path, params: { expense: { name: "ランチ", amount: 800, date: Date.today } }
      }.to change(Expense, :count).by(1)
    end

    it "does not create an expense with amount of zero" do
      expect {
        post expenses_path, params: { expense: { name: "テスト", amount: 0, date: Date.today } }
      }.not_to change(Expense, :count)
    end
  end

  describe "DELETE /expenses/:id" do
    before { sign_in user }

    let!(:expense) { create(:expense, user: user) }

    it "deletes the user's own expense" do
      expect {
        delete expense_path(expense)
      }.to change(Expense, :count).by(-1)
    end
  end
end
