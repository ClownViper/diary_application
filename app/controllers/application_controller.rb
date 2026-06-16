# Base controller: authentication, Devise parameter configuration, and locale setup
class ApplicationController < ActionController::Base
  include FeatureGuarded

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,         keys: [:name])
    devise_parameter_sanitizer.permit(:account_update,  keys: [:name])
  end

  # Transfer session locale to user record immediately after sign-in
  def after_sign_in_path_for(resource)
    if session[:locale].present?
      resource.update(locale: session[:locale])
      session.delete(:locale)
    end
    super
  end

  # Preserve current locale in session so the login page keeps the same language
  def after_sign_out_path_for(resource_or_scope)
    session[:locale] = I18n.locale.to_s
    super
  end

  # Set locale from user preference (logged-in) or session (guest)
  def set_locale
    locale = if user_signed_in?
      current_user.locale.presence
    else
      session[:locale].presence
    end
    I18n.locale = locale || I18n.default_locale
  end
end