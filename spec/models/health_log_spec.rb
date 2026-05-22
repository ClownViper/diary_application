require "rails_helper"

RSpec.describe HealthLog, type: :model do
  describe "validations" do
    let(:user) { create(:user) }

    it "is valid with a date" do
      log = build(:health_log, user: user)
      expect(log).to be_valid
    end

    it "is invalid without a date" do
      log = build(:health_log, user: user, date: nil)
      expect(log).not_to be_valid
      expect(log.errors[:date]).to be_present
    end

    it "rejects duplicate date for the same user" do
      date = Date.today
      create(:health_log, user: user, date: date)
      log2 = build(:health_log, user: user, date: date)
      expect(log2).not_to be_valid
    end

    it "is invalid when condition is outside 1-5" do
      log = build(:health_log, user: user, condition: 6)
      expect(log).not_to be_valid
      expect(log.errors[:condition]).to be_present
    end

    it "is invalid when weight is zero or less" do
      log = build(:health_log, user: user, weight: 0)
      expect(log).not_to be_valid
    end

    it "is valid when weight is nil (optional field)" do
      log = build(:health_log, user: user, weight: nil)
      expect(log).to be_valid
    end
  end

  describe "#condition_label" do
    it "returns the label for the given condition level" do
      log = build(:health_log, condition: 3)
      expect(log.condition_label).to eq("普通")
    end

    it "returns the Japanese label for condition level 5" do
      log = build(:health_log, condition: 5)
      expect(log.condition_label).to eq("とても良い")
    end
  end
end
