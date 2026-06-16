# Server-side guard for feature flags. Feature toggles only hide items from the
# sidebar/dashboard; without this, a disabled feature's pages stay reachable by
# typing the URL directly. Controllers declare `requires_feature :feature_xxx`.
module FeatureGuarded
  extend ActiveSupport::Concern

  class_methods do
    def requires_feature(flag, **options)
      before_action(options) { ensure_feature_enabled(flag) }
    end
  end

  private

  def ensure_feature_enabled(flag)
    return if current_user&.public_send(flag)

    redirect_to root_path, alert: t("feature_guard.disabled")
  end
end
