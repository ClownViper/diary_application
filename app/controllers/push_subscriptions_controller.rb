# Web Push通知のサブスクリプション登録API
class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: params[:endpoint]
    )
    subscription.p256dh = params[:keys][:p256dh]
    subscription.auth = params[:keys][:auth]

    if subscription.save
      render json: { success: true }, status: :ok
    else
      render json: { error: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
