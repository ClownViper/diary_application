require "rails_helper"

RSpec.describe Expense, type: :model do
  describe "validations" do
    let(:user) { create(:user) }

    it "is valid with name, amount, and date" do
      expense = build(:expense, user: user)
      expect(expense).to be_valid
    end

    it "is invalid without a name" do
      expense = build(:expense, user: user, name: nil)
      expect(expense).not_to be_valid
      expect(expense.errors[:name]).to be_present
    end

    it "is invalid without an amount" do
      expense = build(:expense, user: user, amount: nil)
      expect(expense).not_to be_valid
    end

    it "is invalid when amount is zero or less" do
      expense = build(:expense, user: user, amount: 0)
      expect(expense).not_to be_valid
      expect(expense.errors[:amount]).to be_present
    end

    it "is invalid when amount is negative" do
      expense = build(:expense, user: user, amount: -100)
      expect(expense).not_to be_valid
    end

    it "is valid with a positive integer amount" do
      expense = build(:expense, user: user, amount: 1000)
      expect(expense).to be_valid
    end

    it "is invalid without a date" do
      expense = build(:expense, user: user, date: nil)
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to be_present
    end
  end
end
