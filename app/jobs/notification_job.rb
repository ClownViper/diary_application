# Job executed every minute to send Web Push notifications

class NotificationJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current
    current_time = now.strftime("%H:%M")
    today = Date.current

    # Diary: notify users whose time matches and have no diary entry today
    notify_users(:diary, current_time) do |user|
      user.diaries.where(date: today).none?
    end

    # Expenses: notify users whose time matches
    notify_users(:entry, current_time)

    # Health log: notify users whose time matches and have no health log today
    notify_users(:health, current_time) do |user|
      user.health_logs.where(date: today).none?
    end

    # Reading log: notify users whose time matches and have a book in progress
    notify_users(:books, current_time) do |user|
      user.books.reading.any?
    end

    # Schedule: notify users N minutes before their event starts
    send_schedule_notifications(now)
  end

  private

  # Column definitions per notification feature
  NOTIFICATION_COLUMNS = {
    diary:  { flag: :notify_diary,  time: :notify_diary_time },
    entry:  { flag: :notify_entry,  time: :notify_entry_time },
    health: { flag: :notify_health, time: :notify_health_time },
    books:  { flag: :notify_books,  time: :notify_books_time }
  }.freeze

  # Send notifications to eligible users for the given feature
  def notify_users(feature, current_time)
    columns = NOTIFICATION_COLUMNS[feature]
    return unless columns

    users = User.where(columns[:flag] => true)
                .where.not(columns[:time] => nil)

    users.find_each do |user|
      # Compare notification time (HH:MM only)
      notify_time = user.public_send(columns[:time]).strftime("%H:%M")
      next unless notify_time == current_time

      # Check optional eligibility condition
      next if block_given? && !yield(user)

      message = I18n.t("notifications.#{feature}")
      send_push_notification(user, message)
    end
  end

  # Send schedule-based notifications
  def send_schedule_notifications(now)
    User.where(notify_schedule: true).find_each do |user|
      minutes_before = user.notify_schedule_before || 10

      # Find today's schedules that start in exactly N minutes
      user.schedules.where(date: Date.current).find_each do |schedule|
        next unless schedule.start_time.present?

        # Combine schedule start time with today's date
        schedule_time = Time.zone.local(
          now.year, now.month, now.day,
          schedule.start_time.hour, schedule.start_time.min
        )
        notify_at = schedule_time - minutes_before.minutes

        # Check if the notification time matches the current minute
        if notify_at.strftime("%H:%M") == now.strftime("%H:%M")
          message = I18n.t("notifications.schedule", title: schedule.title)
          send_push_notification(user, message)
        end
      end
    end
  end

  # Send a Web Push notification to all subscriptions of the given user
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
        Rails.logger.error("Push notification error: #{e.message}")
      end
    end
  end
end
