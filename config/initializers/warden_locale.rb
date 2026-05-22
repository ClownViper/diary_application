# Set the correct locale before Warden handles authentication failures.
# Without this, flash messages like "please sign in" are always rendered
# in the default locale (ja) because Warden runs before the controller's
# before_action :set_locale.
Rails.application.config.after_initialize do
  Warden::Manager.before_failure do |env, _opts|
    session = env["action_dispatch.request.session"]
    locale  = session&.[](:locale).presence || I18n.default_locale.to_s
    I18n.locale = locale.to_sym
  end
end
