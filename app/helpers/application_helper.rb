# Application-wide view helpers, UI classes, and button utilities
module ApplicationHelper
  # App name and subtitle loaded from config/app.yml
  def app_name
    Rails.application.config.app[:name]
  end

  def app_subtitle
    Rails.application.config.app[:subtitle]
  end

  # Formats a date as "YYYY/MM/DD"
  def format_date(date)
    date&.strftime("%Y/%m/%d")
  end

  # Returns a BCP 47 language tag for the current locale.
  # Used on <html> and <input type="date"> so Chrome renders date fields in the correct format.
  def bcp47_locale
    I18n.locale == :en ? "en-US" : "ja-JP"
  end

  def sidebar_link_to(name, path, html_options = {})
    active = current_page?(path)

    base_classes = [
      "block text-lg px-3 py-2 rounded transition"
    ]

    if active
      base_classes << "bg-white text-slate-700 font-semibold"
    else
      base_classes << "text-white hover:bg-slate-500 hover:text-white"
    end

    if html_options[:class].present?
      base_classes << html_options[:class]
    end

    link_to name, path, class: base_classes.join(" ")
  end

  BUTTON_VARIANTS = {
    primary:   "bg-slate-600 text-white hover:bg-slate-700 shadow",
    secondary: "border border-slate-500 text-slate-600 hover:bg-slate-50",
    danger:    "border border-red-500 text-red-600 hover:bg-red-50",
    compact:   "px-3 py-0.5 border border-slate-500 text-slate-600 rounded-md text-sm hover:bg-slate-500 hover:text-white transition whitespace-nowrap",
    ghost:     "text-gray-500 hover:underline border-0 shadow-none"
  }.freeze

  BUTTON_SIZES = {
    sm: "px-3 py-1 text-sm",
    md: "px-4 py-2",
    lg: "px-6 py-2"
  }.freeze

  INPUT_CLASS       = "w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-slate-300 focus:border-slate-400".freeze
  # Common style for date/time inputs (fixed height + appearance-none to prevent iOS jitter)
  DATE_INPUT_CLASS  = "w-full md:max-w-[33%] h-[42px] bg-white appearance-none".freeze
  # Common style for file input UI
  FILE_INPUT_CLASS  = "block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-slate-50 file:text-slate-700 hover:file:bg-slate-100".freeze
  LABEL_CLASS       = "block text-lg font-semibold mb-1".freeze
  SEARCH_LABEL_CLASS = "block text-sm font-semibold mb-1".freeze

  def ui_button_classes(variant: :primary, size: :md)
    return BUTTON_VARIANTS[:ghost] if variant == :ghost
    return BUTTON_VARIANTS[:compact] if variant == :compact

    base = "inline-block rounded-lg transition font-medium text-center"
    [ base, BUTTON_VARIANTS.fetch(variant), BUTTON_SIZES.fetch(size) ].join(" ")
  end
  def ui_link_button(label, url, variant: :primary, size: :md, **options)
    options[:class] = [ ui_button_classes(variant: variant, size: size), options[:class] ].compact.join(" ")
    link_to label, url, **options
  end
  def ui_back_link(label, path)
    ui_link_button label, path, variant: :ghost
  end
end
