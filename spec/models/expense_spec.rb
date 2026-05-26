require "rails_helper"

RSpec.describe Expense, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }

    it "品目・金額・日付があれば有効" do
      expense = build(:expense, user: user)
      expect(expense).to be_valid
    end

    it "品目がなければ無効" do
      expense = build(:expense, user: user, name: nil)
      expect(expense).not_to be_valid
      expect(expense.errors[:name]).to be_present
    end

    it "金額がなければ無効" do
      expense = build(:expense, user: user, amount: nil)
      expect(expense).not_to be_valid
    end

    it "金額が0以下なら無効" do
      expense = build(:expense, user: user, amount: 0)
      expect(expense).not_to be_valid
      expect(expense.errors[:amount]).to be_present
    end

    it "金額が負の値なら無効" do
      expense = build(:expense, user: user, amount: -100)
      expect(expense).not_to be_valid
    end

    it "金額が正の整数なら有効" do
      expense = build(:expense, user: user, amount: 1000)
      expect(expense).to be_valid
    end

    it "日付がなければ無効" do
      expense = build(:expense, user: user, date: nil)
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to be_present
    end
  end
end
