# CSVエクスポート・インポートを一元管理するコントローラー
class CsvExportsController < ApplicationController
  before_action :authenticate_user!

  def index
    # ダウンロードページ（一覧表示のみ）
  end

  # === エクスポート ===

  def diaries
    diaries = current_user.diaries.order(date: :desc)
    send_csv(generate_diaries_csv(diaries), "diaries_#{Date.today}.csv")
  end

  def expenses
    expenses = current_user.expenses.includes(:category).order(date: :desc)
    send_csv(generate_expenses_csv(expenses), "expenses_#{Date.today}.csv")
  end

  def health_logs
    health_logs = current_user.health_logs.order(date: :desc)
    send_csv(generate_health_logs_csv(health_logs), "health_logs_#{Date.today}.csv")
  end

  def books
    books = current_user.books.order(created_at: :desc)
    send_csv(generate_books_csv(books), "books_#{Date.today}.csv")
  end

  # === インポート ===

  def import_diaries
    return redirect_to csv_exports_path, alert: "ファイルを選択してください。" unless params[:file].present?

    result = import_csv(params[:file]) do |row|
      date = parse_date(row["日付"])
      next if date.nil?
      next if current_user.diaries.exists?(date: date)

      current_user.diaries.create!(
        date:  date,
        title: row["タイトル"].presence || "(タイトルなし)",
        body:  row["本文"]
      )
    end

    redirect_to csv_exports_path, notice: "#{result[:success]}件をインポートしました。#{result[:skip] > 0 ? "（#{result[:skip]}件スキップ）" : ''}"
  rescue StandardError => e
    redirect_to csv_exports_path, alert: "インポートに失敗しました: #{e.message}"
  end

  def import_expenses
    return redirect_to csv_exports_path, alert: "ファイルを選択してください。" unless params[:file].present?

    result = import_csv(params[:file]) do |row|
      date = parse_date(row["日付"])
      next if date.nil?

      category = row["カテゴリ"].present? ? current_user.categories.find_or_create_by(name: row["カテゴリ"]) : nil

      current_user.expenses.create!(
        date:        date,
        name:        row["品目"].presence || "(品目なし)",
        amount:      row["金額"].to_i,
        category:    category,
        memo:        row["メモ"]
      )
    end

    redirect_to csv_exports_path, notice: "#{result[:success]}件をインポートしました。#{result[:skip] > 0 ? "（#{result[:skip]}件スキップ）" : ''}"
  rescue StandardError => e
    redirect_to csv_exports_path, alert: "インポートに失敗しました: #{e.message}"
  end

  def import_health_logs
    return redirect_to csv_exports_path, alert: "ファイルを選択してください。" unless params[:file].present?

    result = import_csv(params[:file]) do |row|
      date = parse_date(row["日付"])
      next if date.nil?
      next if current_user.health_logs.exists?(date: date)

      condition_value = HealthLog::CONDITION_LABELS.key(row["体調"])

      current_user.health_logs.create!(
        date:        date,
        weight:      row["体重(kg)"].presence&.to_f,
        condition:   condition_value,
        sleep_hours: row["睡眠(h)"].presence&.to_f,
        temperature: row["体温(℃)"].presence&.to_f,
        memo:        row["メモ"]
      )
    end

    redirect_to csv_exports_path, notice: "#{result[:success]}件をインポートしました。#{result[:skip] > 0 ? "（#{result[:skip]}件スキップ）" : ''}"
  rescue StandardError => e
    redirect_to csv_exports_path, alert: "インポートに失敗しました: #{e.message}"
  end

  def import_books
    return redirect_to csv_exports_path, alert: "ファイルを選択してください。" unless params[:file].present?

    result = import_csv(params[:file]) do |row|
      next if row["タイトル"].blank?

      status_key = Book::STATUS_LABELS.key(row["ステータス"]) || "unread"

      current_user.books.create!(
        title:       row["タイトル"],
        author:      row["著者"],
        status:      status_key,
        started_on:  parse_date(row["読み始め日"]),
        finished_on: parse_date(row["読了日"]),
        memo:        row["感想"]
      )
    end

    redirect_to csv_exports_path, notice: "#{result[:success]}件をインポートしました。#{result[:skip] > 0 ? "（#{result[:skip]}件スキップ）" : ''}"
  rescue StandardError => e
    redirect_to csv_exports_path, alert: "インポートに失敗しました: #{e.message}"
  end

  private

  def send_csv(data, filename)
    send_data data,
              filename: filename,
              type: "text/csv; charset=UTF-8",
              disposition: "attachment"
  end

  # CSVを読み込んでブロックを実行し、成功/スキップ件数を返す
  def import_csv(file)
    require "csv"
    content = file.read.force_encoding("UTF-8")
    # BOM除去
    content = content.delete_prefix("\xEF\xBB\xBF")
    success = 0
    skip    = 0

    CSV.parse(content, headers: true) do |row|
      result = yield row
      if result.nil?
        skip += 1
      else
        success += 1
      end
    end

    { success: success, skip: skip }
  end

  def parse_date(str)
    return nil if str.blank?
    Date.strptime(str.strip, "%Y/%m/%d")
  rescue ArgumentError
    nil
  end

  # === CSV生成 ===

  def generate_diaries_csv(diaries)
    require "csv"
    bom = "\xEF\xBB\xBF"
    bom + CSV.generate(encoding: "UTF-8", row_sep: "\r\n") do |csv|
      csv << [ "日付", "タイトル", "本文" ]
      diaries.each do |d|
        csv << [ d.date.strftime("%Y/%m/%d"), d.title, d.body ]
      end
    end
  end

  def generate_expenses_csv(expenses)
    require "csv"
    bom = "\xEF\xBB\xBF"
    bom + CSV.generate(encoding: "UTF-8", row_sep: "\r\n") do |csv|
      csv << [ "日付", "品目", "金額", "カテゴリ", "メモ" ]
      expenses.each do |e|
        csv << [ e.date.strftime("%Y/%m/%d"), e.name, e.amount, e.category&.name, e.memo ]
      end
    end
  end

  def generate_health_logs_csv(health_logs)
    require "csv"
    bom = "\xEF\xBB\xBF"
    bom + CSV.generate(encoding: "UTF-8", row_sep: "\r\n") do |csv|
      csv << [ "日付", "体重(kg)", "体調", "睡眠(h)", "体温(℃)", "メモ" ]
      health_logs.each do |l|
        csv << [ l.date.strftime("%Y/%m/%d"), l.weight, l.condition_label, l.sleep_hours, l.temperature, l.memo ]
      end
    end
  end

  def generate_books_csv(books)
    require "csv"
    bom = "\xEF\xBB\xBF"
    bom + CSV.generate(encoding: "UTF-8", row_sep: "\r\n") do |csv|
      csv << [ "タイトル", "著者", "ステータス", "読み始め日", "読了日", "感想" ]
      books.each do |b|
        csv << [
          b.title,
          b.author,
          b.status_label,
          b.started_on&.strftime("%Y/%m/%d"),
          b.finished_on&.strftime("%Y/%m/%d"),
          b.memo
        ]
      end
    end
  end
end
