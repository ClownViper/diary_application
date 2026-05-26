require "rails_helper"

RSpec.describe "HealthLogs", type: :request do
  let(:user) { create(:user) }

  describe "認証" do
    it "未ログインはリダイレクト" do
      get health_logs_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /health_logs" do
    before { sign_in user }

    it "一覧ページが表示される" do
      create_list(:health_log, 3, user: user)
      get health_logs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /health_logs/stats" do
    before { sign_in user }

    it "統計ページが表示される" do
      get stats_health_logs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /health_logs" do
    before { sign_in user }

    it "有効なパラメータで体調ログを作成できる" do
      expect {
        post health_logs_path, params: { health_log: { date: Date.today, condition: 3, weight: 60.0 } }
      }.to change(HealthLog, :count).by(1)
    end

    it "日付がなければ作成できない" do
      expect {
        post health_logs_path, params: { health_log: { date: nil, condition: 3 } }
      }.not_to change(HealthLog, :count)
    end
  end
end
