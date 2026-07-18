require "csv"

# Imports CSV rows into a user's records, returning success/skip counts.
# Each importer skips a row by having its block return nil/false (via `next`).
class CsvImporter
  def initialize(user)
    @user = user
  end

  def import_diaries(file)
    cols = I18n.t("csv_exports.csv_columns.diary")
    import_csv(file) do |row|
      date = parse_date(row[cols[:date]])
      next if date.nil?
      next if @user.diaries.exists?(date: date)

      @user.diaries.create!(
        date:  date,
        title: row[cols[:title]].presence || I18n.t("csv_exports.import_defaults.no_title"),
        body:  row[cols[:body]]
      )
    end
  end

  def import_expenses(file)
    cols = I18n.t("csv_exports.csv_columns.expense")
    import_csv(file) do |row|
      date = parse_date(row[cols[:date]])
      next if date.nil?

      category = row[cols[:category]].present? ? @user.categories.find_or_create_by(name: row[cols[:category]]) : nil

      @user.expenses.create!(
        date:     date,
        name:     row[cols[:name]].presence || I18n.t("csv_exports.import_defaults.no_name"),
        amount:   row[cols[:amount]].to_i,
        category: category,
        memo:     row[cols[:memo]]
      )
    end
  end

  def import_health_logs(file)
    cols = I18n.t("csv_exports.csv_columns.health_log")
    import_csv(file) do |row|
      date = parse_date(row[cols[:date]])
      next if date.nil?
      next if @user.health_logs.exists?(date: date)

      condition_value = HealthLog.condition_labels.key(row[cols[:condition]])

      @user.health_logs.create!(
        date:        date,
        weight:      row[cols[:weight]].presence&.to_f,
        condition:   condition_value,
        sleep_hours: row[cols[:sleep_hours]].presence&.to_f,
        temperature: row[cols[:temperature]].presence&.to_f,
        memo:        row[cols[:memo]]
      )
    end
  end

  def import_books(file)
    cols = I18n.t("csv_exports.csv_columns.book")
    import_csv(file) do |row|
      next if row[cols[:title]].blank?

      status_key = Book.statuses.keys.find { |k| I18n.t("books.status_labels.#{k}") == row[cols[:status]] } || "unread"

      @user.books.create!(
        title:       row[cols[:title]],
        author:      row[cols[:author]],
        status:      status_key,
        started_on:  parse_date(row[cols[:started_on]]),
        finished_on: parse_date(row[cols[:finished_on]]),
        memo:        row[cols[:memo]]
      )
    end
  end

  private

  # Parse CSV file, execute block per row, return success/skip counts
  def import_csv(file)
    raw = file.read
    content = raw.dup.force_encoding("UTF-8")
    unless content.valid_encoding?
      content = raw.dup.force_encoding("Shift_JIS").encode("UTF-8", invalid: :replace, undef: :replace)
    end
    # Strip BOM (UTF-8 BOM: U+FEFF)
    content = content.delete_prefix("\u{FEFF}")
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

  DATE_FORMATS = [ "%Y/%m/%d", "%Y-%m-%d", "%m/%d/%y", "%m-%d-%y", "%m/%d/%Y", "%m-%d-%Y" ].freeze

  def parse_date(str)
    return nil if str.blank?
    DATE_FORMATS.each do |fmt|
      date = Date.strptime(str.strip, fmt)
      date = Date.new(date.year + 2000, date.month, date.day) if date.year < 100
      return date
    rescue ArgumentError
      next
    end
    nil
  end
end
