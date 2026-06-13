require "csv"

# Builds BOM-prefixed CSV exports (Excel-compatible) for a user's records.
class CsvExporter
  def initialize(user)
    @user = user
  end

  def diaries
    cols = I18n.t("csv_exports.csv_columns.diary")
    csv_with_bom do |csv|
      csv << cols.values
      @user.diaries.order(date: :desc).each do |d|
        csv << [ d.date.strftime("%Y/%m/%d"), d.title, d.body ]
      end
    end
  end

  def expenses
    cols = I18n.t("csv_exports.csv_columns.expense")
    csv_with_bom do |csv|
      csv << cols.values
      @user.expenses.includes(:category).order(date: :desc).each do |e|
        csv << [ e.date.strftime("%Y/%m/%d"), e.name, e.amount, e.category&.name, e.memo ]
      end
    end
  end

  def health_logs
    cols = I18n.t("csv_exports.csv_columns.health_log")
    csv_with_bom do |csv|
      csv << cols.values
      @user.health_logs.order(date: :desc).each do |l|
        csv << [ l.date.strftime("%Y/%m/%d"), l.weight, l.condition_label, l.sleep_hours, l.temperature, l.memo ]
      end
    end
  end

  def books
    cols = I18n.t("csv_exports.csv_columns.book")
    csv_with_bom do |csv|
      csv << cols.values
      @user.books.order(created_at: :desc).each do |b|
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

  private

  # Generate BOM-prefixed CSV for Excel compatibility
  def csv_with_bom(&block)
    csv_body = CSV.generate(encoding: "UTF-8", row_sep: "\r\n", &block)
    # Prepend BOM as a UTF-8 string literal (\xEF\xBB\xBF would be ASCII-8BIT and cause encoding errors)
    "\u{FEFF}" + csv_body
  end
end
