# Custom sessions controller to ensure flash messages use the user's locale
class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)

    # Prioritize: session (explicit choice on login page) > user's saved locale > default
    I18n.locale = (session[:locale].presence || resource.locale.presence || I18n.default_locale.to_s).to_sym

    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end
