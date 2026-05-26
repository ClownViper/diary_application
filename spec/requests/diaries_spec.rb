require "rails_helper"

RSpec.describe "Diaries", type: :request do
  let(:user) { create(:user) }

  describe "認証" do
    it "未ログインはリダイレクト" do
      get diaries_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /diaries" do
    before { sign_in user }

    it "一覧ページが表示される" do
      create_list(:diary, 3, user: user)
      get diaries_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /diaries" do
    before { sign_in user }

    it "有効なパラメータで日記を作成できる" do
      expect {
        post diaries_path, params: { diary: { title: "テスト日記", date: Date.today, body: "本文" } }
      }.to change(Diary, :count).by(1)
    end

    it "無効なパラメータでは作成できない" do
      expect {
        post diaries_path, params: { diary: { title: nil, date: Date.today } }
      }.not_to change(Diary, :count)
    end
  end

  describe "PATCH /diaries/:id" do
    before { sign_in user }

    let!(:diary) { create(:diary, user: user) }

    it "自分の日記を更新できる" do
      patch diary_path(diary), params: { diary: { title: "更新後タイトル" } }
      expect(diary.reload.title).to eq("更新後タイトル")
    end

    it "他のユーザーの日記は更新できない" do
      other_diary = create(:diary, user: create(:user))
      patch diary_path(other_diary), params: { diary: { title: "不正更新" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /diaries/:id" do
    before { sign_in user }

    let!(:diary) { create(:diary, user: user) }

    it "自分の日記を削除できる" do
      expect {
        delete diary_path(diary)
      }.to change(Diary, :count).by(-1)
    end
  end
end
