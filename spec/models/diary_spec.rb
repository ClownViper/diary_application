require "rails_helper"

RSpec.describe Diary, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }

    it "タイトル・日付があれば有効" do
      diary = build(:diary, user: user)
      expect(diary).to be_valid
    end

    it "タイトルがなければ無効" do
      diary = build(:diary, user: user, title: nil)
      expect(diary).not_to be_valid
      expect(diary.errors[:title]).to be_present
    end

    it "日付がなければ無効" do
      diary = build(:diary, user: user, date: nil)
      expect(diary).not_to be_valid
      expect(diary.errors[:date]).to be_present
    end

    it "同じユーザーの同じ日付は重複不可" do
      date = Date.today
      create(:diary, user: user, date: date)
      diary2 = build(:diary, user: user, date: date)
      expect(diary2).not_to be_valid
      expect(diary2.errors[:date]).to be_present
    end

    it "異なるユーザーなら同じ日付でも有効" do
      other_user = create(:user)
      date = Date.today
      create(:diary, user: user, date: date)
      diary2 = build(:diary, user: other_user, date: date)
      expect(diary2).to be_valid
    end
  end
end
