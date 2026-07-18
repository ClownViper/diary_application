# Controller for CSV export and import
class CsvExportsController < ApplicationController
  def index
    # Display-only download/upload page
  end

  # === Export ===

  def diaries
    send_csv(exporter.diaries, "diaries_#{Date.current}.csv")
  end

  def expenses
    send_csv(exporter.expenses, "expenses_#{Date.current}.csv")
  end

  def health_logs
    send_csv(exporter.health_logs, "health_logs_#{Date.current}.csv")
  end

  def books
    send_csv(exporter.books, "books_#{Date.current}.csv")
  end

  # === Import ===

  def import_diaries
    import_and_redirect { importer.import_diaries(params[:file]) }
  end

  def import_expenses
    import_and_redirect { importer.import_expenses(params[:file]) }
  end

  def import_health_logs
    import_and_redirect { importer.import_health_logs(params[:file]) }
  end

  def import_books
    import_and_redirect { importer.import_books(params[:file]) }
  end

  private

  def exporter
    @exporter ||= CsvExporter.new(current_user)
  end

  def importer
    @importer ||= CsvImporter.new(current_user)
  end

  # Guard for a missing file, run the import, and redirect with a flash message
  def import_and_redirect
    return redirect_to csv_exports_path, alert: t("csv_exports.flash.no_file") unless params[:file].present?

    result = yield
    redirect_to csv_exports_path, notice: import_flash(result)
  rescue StandardError => e
    redirect_to csv_exports_path, alert: t("csv_exports.flash.import_error", message: e.message)
  end

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
end
