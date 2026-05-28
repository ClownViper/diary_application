# Controller for CSV export and import
class CsvExportsController < ApplicationController

  def index
    # Display-only download/upload page
  end

  # === Export ===

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

  # === Import ===

  def import_diaries
    return redirect_to csv_exports_path, alert: t("csv_exports.flash.no_file") unless params[:file].present?

    cols = I18n.t("csv_exports.csv_columns.diary")
    result = import_csv(params[:file]) do |row|
      date = parse_date(row[cols[:date]])
      next if date.nil?
      next if current_user.diaries.exists?(date: date)

      current_user.diaries.create!(
        date:  date,
        title: row[cols[:title]].presence || t("csv_exports.import_defaults.no_title"),
        body:  row[cols[:body]]
      )
    end

    redirect_to csv_exports_path, notice: import_flash(result)
  rescue StandardError => e
    redirect_to csv_exports_path, alert: t("csv_exports.flash.import_error", message: e.message)
  end

  def import_expenses
    return redirect_to csv_exports_path, alert: t("csv_exports.flash.no_file") unless params[:file].present?

    cols = I18n.t("csv_exports.csv_columns.expense")
    result = import_csv(params[:file]) do |row|
      date = parse_date(row[cols[:date]])
      next if date.nil?

      category = row[cols[:category]].present? ? current_user.categories.find_or_create_by(name: row[cols[:category]]) : nil

      current_user.expenses.create!(
        date:        date,
        name:        row[cols[:name]].presence || t("csv_exports.import_defaults.no_name"),
        amount:      row[cols[:amount]].to_i,
        category:    category,
        memo:        row[cols[:memo]]
      )
    end

    redirect_to csv_exports_path, notice: import_flash(result)
  rescue StandardError => e
    redirect_to csv_exports_path, alert: t("csv_exports.flash.import_error", message: e.message)
  end

  def import_health_logs
    return redirect_to csv_exports_path, alert: t("csv_exports.flash.no_file") unless params[:file].present?

    cols = I18n.t("csv_exports.csv_columns.health_log")
    result = import_csv(params[:file]) do |row|
      date = parse_date(row[cols[:date]])
      next if date.nil?
      next if current_user.health_logs.exists?(date: date)

      condition_value = HealthLog.condition_labels.key(row[cols[:condition]])

      current_user.health_logs.create!(
        date:        date,
        weight:      row[cols[:weight]].presence&.to_f,
        condition:   condition_value,
        sleep_hours: row[cols[:sleep_hours]].presence&.to_f,
        temperature: row[cols[:temperature]].presence&.to_f,
        memo:        row[cols[:memo]]
      )
    end

    redirect_to csv_exports_path, notice: import_flash(result)
  rescue StandardError => e
    redirect_to csv_exports_path, alert: t("csv_exports.flash.import_error", message: e.message)
  end

  def import_books
    return redirect_to csv_exports_path, alert: t("csv_exports.flash.no_file") unless params[:file].present?

    cols = I18n.t("csv_exports.csv_columns.book")
    result = import_csv(params[:file]) do |row|
      next if row[cols[:title]].blank?

      status_key = Book.statuses.keys.find { |k| I18n.t("books.status_labels.#{k}") == row[cols[:status]] } || "unread"

      current_user.books.create!(
        title:       row[cols[:title]],
        author:      row[cols[:author]],
        status:      status_key,
        started_on:  parse_date(row[cols[:started_on]]),
        finished_on: parse_date(row[cols[:finished_on]]),
        memo:        row[cols[:memo]]
      )
    end

    redirect_to csv_exports_path, notice: import_flash(result)
  rescue StandardError => e
    redirect_to csv_exports_path, alert: t("csv_exports.flash.import_error", message: e.message)
  end

  private

  def import_flash(result)
    if result[:skip] > 0
      t("csv_exports.flash.import_success_skip", success: result[:success], skip: result[:skip])
    else
      t("csv_exports.flash.import_success", success: result[:success])
    end
  end

  def send_csv(data, filename)
    send_data data,
              filename: filename,
              type: "text/csv; charset=UTF-8",
              disposition: "attachment"
  end

  # Parse CSV file, execute block per row, return success/skip counts
  def import_csv(file)
    require "csv"
    content = file.read.force_encoding("UTF-8")
    # Strip BOM (UTF-8 BOM: U+FEFF)
    content = content.delete_prefix("﻿")
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

  # === CSV Generation ===

  # Generate BOM-prefixed CSV for Excel compatibility
  def csv_with_bom(&block)
    require "csv"
    csv_body = CSV.generate(encoding: "UTF-8", row_sep: "\r\n", &block)
    # Prepend BOM as a UTF-8 string literal (\xEF\xBB\xBF would be ASCII-8BIT and cause encoding errors)
    "﻿" + csv_body
  end

  def generate_diaries_csv(diaries)
    cols = I18n.t("csv_exports.csv_columns.diary")
    csv_with_bom do |csv|
      csv << cols.values
      diaries.each do |d|
        csv << [ d.date.strftime("%Y/%m/%d"), d.title, d.body ]
      end
    end
  end

  def generate_expenses_csv(expenses)
    cols = I18n.t("csv_exports.csv_columns.expense")
    csv_with_bom do |csv|
      csv << cols.values
      expenses.each do |e|
        csv << [ e.date.strftime("%Y/%m/%d"), e.name, e.amount, e.category&.name, e.memo ]
      end
    end
  end

  def generate_health_logs_csv(health_logs)
    cols = I18n.t("csv_exports.csv_columns.health_log")
    csv_with_bom do |csv|
      csv << cols.values
      health_logs.each do |l|
        csv << [ l.date.strftime("%Y/%m/%d"), l.weight, l.condition_label, l.sleep_hours, l.temperature, l.memo ]
      end
    end
  end

  def generate_books_csv(books)
    cols = I18n.t("csv_exports.csv_columns.book")
    csv_with_bom do |csv|
      csv << cols.values
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
