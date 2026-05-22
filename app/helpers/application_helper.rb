module ApplicationHelper
	def sidebar_link_to(name, path, html_options = {})
		active = current_page?(path)

		base_classes = [
			"block text-lg px-3 py-2 rounded transition",
		]

		if active
			base_classes << "bg-white text-blue-700 font-semibold"
		else
			base_classes << "text-white hover:bg-blue-300 hover:text-white"
		end

		if html_options[:class].present?
			base_classes << html_options[:class]
		end

		link_to name, path, class: base_classes.join(" ")
	end

	BUTTON_VARIANTS = {
    primary: "bg-blue-600 text-white hover:bg-blue-700 shadow",
    secondary: "border border-blue-500 text-blue-600 hover:bg-blue-50",
    danger: "border border-red-500 text-red-600 hover:bg-red-50",
		compact: "px-3 py-0.5 border border-blue-500 text-blue-600 rounded-md text-sm hover:bg-blue-500 hover:text-white transition",
    ghost: "text-gray-500 hover:underline border-0 shadow-none"
  }.freeze
  BUTTON_SIZES = {
    sm: "px-3 py-1 text-sm",
    md: "px-4 py-2",
    lg: "px-6 py-2"
  }.freeze
  INPUT_CLASS = "w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400".freeze
  # 日付・時刻入力の共通スタイル（iPhoneのブレ対策：高さ固定・appearance-none）
  DATE_INPUT_CLASS = "w-full md:max-w-[33%] h-[42px] bg-white appearance-none".freeze
  # ファイル選択UIの共通スタイル（読書ログのUIを基準）
  FILE_INPUT_CLASS = "block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100".freeze
  LABEL_CLASS = "block text-lg font-semibold mb-1".freeze
	SEARCH_LABEL_CLASS = "block text-sm font-semibold mb-1".freeze
  def ui_button_classes(variant: :primary, size: :md)
    return BUTTON_VARIANTS[:ghost] if variant == :ghost
    return BUTTON_VARIANTS[:compact] if variant == :compact

    base = "inline-block rounded-lg transition font-medium text-center"
    [base, BUTTON_VARIANTS.fetch(variant), BUTTON_SIZES.fetch(size)].join(" ")
  end
  def ui_link_button(label, url, variant: :primary, size: :md, **options)
    options[:class] = [ui_button_classes(variant: variant, size: size), options[:class]].compact.join(" ")
    link_to label, url, **options
  end
  def ui_field(form, attr, label: nil, type: :text_field, **field_options)
    label_text = label || form.object.class.human_attribute_name(attr)
    error = form.object.errors[attr]&.first
    input_classes = [INPUT_CLASS, error.present? ? "border-red-500" : nil].compact.join(" ")
  field_options[:class] = [input_classes, field_options[:class]].compact.join(" ")
    content_tag(:div) do
      safe_join([
        form.label(attr, label_text, class: LABEL_CLASS),
        form.public_send(type, attr, **field_options),
        (content_tag(:p, error, class: "mt-1 text-sm text-red-600") if error.present?)
      ].compact)
    end
  end
	def ui_back_link(label, path)
		ui_link_button label, path, variant: :ghost
	end
end
