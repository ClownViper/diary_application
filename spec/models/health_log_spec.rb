require "rails_helper"

RSpec.describe HealthLog, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }

    it "日付があれば有効" do
      log = build(:health_log, user: user)
      expect(log).to be_valid
    end

    it "日付がなければ無効" do
      log = build(:health_log, user: user, date: nil)
      expect(log).not_to be_valid
      expect(log.errors[:date]).to be_present
    end

    it "同じユーザーの同じ日付は重複不可" do
      date = Date.today
      create(:health_log, user: user, date: date)
      log2 = build(:health_log, user: user, date: date)
      expect(log2).not_to be_valid
    end

    it "体調が1〜5の範囲外なら無効" do
      log = build(:health_log, user: user, condition: 6)
      expect(log).not_to be_valid
      expect(log.errors[:condition]).to be_present
    end

    it "体重が0以下なら無効" do
      log = build(:health_log, user: user, weight: 0)
      expect(log).not_to be_valid
    end

    it "体重がnilなら有効（任意項目）" do
      log = build(:health_log, user: user, weight: nil)
      expect(log).to be_valid
    end
  end

  describe "#condition_label" do
    it "体調レベルに対応するラベルを返す" do
      log = build(:health_log, condition: 3)
      expect(log.condition_label).to eq("普通")
    end

    it "体調レベル5なら「とても良い」を返す" do
      log = build(:health_log, condition: 5)
      expect(log.condition_label).to eq("とても良い")
    end
  end
end
