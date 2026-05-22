require "rails_helper"

RSpec.describe "HealthLogs", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated users" do
      get health_logs_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /health_logs" do
    before { sign_in user }

    it "renders the index page" do
      create_list(:health_log, 3, user: user)
      get health_logs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /health_logs/stats" do
    before { sign_in user }

    it "renders the stats page" do
      get stats_health_logs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /health_logs" do
    before { sign_in user }

    it "creates a health log with valid params" do
      expect {
        post health_logs_path, params: { health_log: { date: Date.today, condition: 3, weight: 60.0 } }
      }.to change(HealthLog, :count).by(1)
    end

    it "does not create a health log with a duplicate date" do
      create(:health_log, user: user, date: Date.today)
      expect {
        post health_logs_path, params: { health_log: { date: Date.today, condition: 3 } }
      }.not_to change(HealthLog, :count)
    end
  end
end
