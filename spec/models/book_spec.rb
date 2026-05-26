require "rails_helper"

RSpec.describe Book, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }

    it "タイトルとステータスがあれば有効" do
      book = build(:book, user: user)
      expect(book).to be_valid
    end

    it "タイトルがなければ無効" do
      book = build(:book, user: user, title: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to be_present
    end

    it "感想が300文字を超えると無効" do
      book = build(:book, user: user, memo: "a" * 301)
      expect(book).not_to be_valid
      expect(book.errors[:memo]).to be_present
    end

    it "感想が300文字以内なら有効" do
      book = build(:book, user: user, memo: "a" * 300)
      expect(book).to be_valid
    end
  end

  describe "#status_label" do
    it "unreadなら「未読」を返す" do
      book = build(:book, status: :unread)
      expect(book.status_label).to eq("未読")
    end

    it "readingなら「読書中」を返す" do
      book = build(:book, status: :reading)
      expect(book.status_label).to eq("読書中")
    end

    it "finishedなら「読了」を返す" do
      book = build(:book, status: :finished)
      expect(book.status_label).to eq("読了")
    end
  end
end
