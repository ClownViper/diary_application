require "rails_helper"

RSpec.describe "Diaries", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated users" do
      get diaries_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /diaries" do
    before { sign_in user }

    it "renders the index page" do
      create_list(:diary, 3, user: user)
      get diaries_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /diaries" do
    before { sign_in user }

    it "creates a diary with valid params" do
      expect {
        post diaries_path, params: { diary: { title: "テスト日記", date: Date.today, body: "本文" } }
      }.to change(Diary, :count).by(1)
    end

    it "does not create a diary with invalid params" do
      expect {
        post diaries_path, params: { diary: { title: nil, date: Date.today } }
      }.not_to change(Diary, :count)
    end
  end

  describe "PATCH /diaries/:id" do
    before { sign_in user }

    let!(:diary) { create(:diary, user: user) }

    it "updates the user's own diary" do
      patch diary_path(diary), params: { diary: { title: "更新後タイトル" } }
      expect(diary.reload.title).to eq("更新後タイトル")
    end

    it "cannot update another user's diary" do
      other_diary = create(:diary, user: create(:user))
      patch diary_path(other_diary), params: { diary: { title: "不正更新" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /diaries/:id" do
    before { sign_in user }

    let!(:diary) { create(:diary, user: user) }

    it "deletes the user's own diary" do
      expect {
        delete diary_path(diary)
      }.to change(Diary, :count).by(-1)
    end
  end
end
