# 毎分実行される通知ジョブ
# 各機能の通知設定を確認し、条件に合致するユーザーにWeb Push通知を送信する
class NotificationJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current
    current_time = now.strftime("%H:%M")
    today = Date.current

    # 日記通知: 通知時刻が一致 && 今日の日記がないユーザー
    notify_users(:diary, current_time) do |user|
      user.diaries.where(date: today).none?
    end

    # 家計簿通知: 通知時刻が一致
    notify_users(:entry, current_time)

    # 体調ログ通知: 通知時刻が一致 && 今日の記録がないユーザー
    notify_users(:health, current_time) do |user|
      user.health_logs.where(date: today).none?
    end

    # 読書ログ通知: 通知時刻が一致 && 読書中の本があるユーザー
    notify_users(:books, current_time) do |user|
      user.books.reading.any?
    end

    # スケジュール通知: 予定の開始前N分に通知
    send_schedule_notifications(now)
  end

  private

  # 指定された機能の通知対象ユーザーに通知を送信
  def notify_users(feature, current_time)
    notify_flag = "notify_#{feature}"
    time_column = "notify_#{feature}_time"

    users = User.where(notify_flag => true)
                .where.not(time_column => nil)

    users.find_each do |user|
      # 通知時刻を比較（時:分のみ）
      notify_time = user.send(time_column).strftime("%H:%M")
      next unless notify_time == current_time

      # 追加条件がある場合はチェック
      next if block_given? && !yield(user)

      message = I18n.t("notifications.#{feature}")
      send_push_notification(user, message)
    end
  end

  # スケジュール通知の送信
  def send_schedule_notifications(now)
    User.where(notify_schedule: true).find_each do |user|
      minutes_before = user.notify_schedule_before || 10

      # 今日のスケジュールで、開始N分前のものを探す
      user.schedules.where(date: Date.current).find_each do |schedule|
        next unless schedule.start_time.present?

        # スケジュールの開始時刻を今日の日付と組み合わせる
        schedule_time = Time.zone.local(
          now.year, now.month, now.day,
          schedule.start_time.hour, schedule.start_time.min
        )
        notify_at = schedule_time - minutes_before.minutes

        # 通知時刻が現在の分と一致するか確認
        if notify_at.strftime("%H:%M") == now.strftime("%H:%M")
          message = I18n.t("notifications.schedule", title: schedule.title)
          send_push_notification(user, message)
        end
      end
    end
  end

  # Web Push通知を送信
  def send_push_notification(user, message)
    vapid_keys = Rails.application.credentials.dig(:webpush)

    return unless vapid_keys.present?

    user.push_subscriptions.find_each do |sub|
      begin
        WebPush.payload_send(
          message: { title: "MyDiary", body: message, icon: "/icon.png" }.to_json,
          endpoint: sub.endpoint,
          p256dh: sub.p256dh,
          auth: sub.auth,
          vapid: {
            subject: "mailto:#{vapid_keys[:subject] || 'noreply@example.com'}",
            public_key: vapid_keys[:public_key],
            private_key: vapid_keys[:private_key]
          }
        )
      rescue WebPush::ExpiredSubscription
        sub.destroy
      rescue => e
        Rails.logger.error("Push通知送信エラー: #{e.message}")
      end
    end
  end
end
