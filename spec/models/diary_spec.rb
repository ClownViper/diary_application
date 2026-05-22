require "rails_helper"

RSpec.describe Diary, type: :model do
  describe "validations" do
    let(:user) { create(:user) }

    it "is valid with title and date" do
      diary = build(:diary, user: user)
      expect(diary).to be_valid
    end

    it "is invalid without a title" do
      diary = build(:diary, user: user, title: nil)
      expect(diary).not_to be_valid
      expect(diary.errors[:title]).to be_present
    end

    it "is invalid without a date" do
      diary = build(:diary, user: user, date: nil)
      expect(diary).not_to be_valid
      expect(diary.errors[:date]).to be_present
    end

    it "rejects duplicate date for the same user" do
      date = Date.today
      create(:diary, user: user, date: date)
      diary2 = build(:diary, user: user, date: date)
      expect(diary2).not_to be_valid
      expect(diary2.errors[:date]).to be_present
    end

    it "allows the same date for different users" do
      other_user = create(:user)
      date = Date.today
      create(:diary, user: user, date: date)
      diary2 = build(:diary, user: other_user, date: date)
      expect(diary2).to be_valid
    end
  end
end
