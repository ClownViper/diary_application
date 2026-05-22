# Controller for switching the application locale
class LocalesController < ApplicationController
  skip_before_action :authenticate_user!

  def update
    locale = params[:locale].to_s.presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale.to_s
    if user_signed_in?
      current_user.update(locale: locale)
    else
      session[:locale] = locale
    end
    redirect_back fallback_location: root_path
  end
end
