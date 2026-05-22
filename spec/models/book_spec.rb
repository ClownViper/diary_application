require "rails_helper"

RSpec.describe Book, type: :model do
  describe "validations" do
    let(:user) { create(:user) }

    it "is valid with title and status" do
      book = build(:book, user: user)
      expect(book).to be_valid
    end

    it "is invalid without a title" do
      book = build(:book, user: user, title: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to be_present
    end

    it "is invalid when memo exceeds 300 characters" do
      book = build(:book, user: user, memo: "a" * 301)
      expect(book).not_to be_valid
      expect(book.errors[:memo]).to be_present
    end

    it "is valid when memo is 300 characters or fewer" do
      book = build(:book, user: user, memo: "a" * 300)
      expect(book).to be_valid
    end
  end

  describe "#status_label" do
    it "returns the Japanese label for unread status" do
      book = build(:book, status: :unread)
      expect(book.status_label).to eq("未読")
    end

    it "returns the Japanese label for reading status" do
      book = build(:book, status: :reading)
      expect(book.status_label).to eq("読書中")
    end

    it "returns the Japanese label for finished status" do
      book = build(:book, status: :finished)
      expect(book.status_label).to eq("読了")
    end
  end
end
