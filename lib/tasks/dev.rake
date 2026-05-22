namespace :dev do
  desc "Seed health log sample data for the entire current year (skips existing records)"
  task seed_health_logs_year: :environment do
    email = ENV["EMAIL"]
    user = email.present? ? User.find_by!(email: email) : User.first

    abort "User not found" unless user

    puts "Target user: #{user.email}"

    base_weight = ENV["WEIGHT"]&.to_f || 65.0
    today = Date.today
    start_date = Date.today.beginning_of_year
    created = 0
    skipped = 0

    (start_date..today).each do |date|
      if user.health_logs.exists?(date: date)
        skipped += 1
        next
      end

      weight = (base_weight + rand(-20..20) / 10.0).round(1)
      condition = [1, 2, 3, 3, 3, 4, 4, 4, 5, 5].sample

      user.health_logs.create!(
        date:      date,
        weight:    weight,
        condition: condition,
        memo:      ""
      )
      created += 1
    end

    puts "Created: #{created} records / Skipped (existing): #{skipped} records"
  end

  desc "Seed health log sample data for the current month (skips existing records)"
  task seed_health_logs: :environment do
    # Resolve target user; defaults to the first user if EMAIL is not specified
    email = ENV["EMAIL"]
    user = email.present? ? User.find_by!(email: email) : User.first

    abort "User not found" unless user

    puts "Target user: #{user.email}"

    base_weight = ENV["WEIGHT"]&.to_f || 65.0  # Base weight; overridable via ENV["WEIGHT"]
    today = Date.today
    start_date = today.beginning_of_month
    created = 0
    skipped = 0

    (start_date..today).each do |date|
      if user.health_logs.exists?(date: date)
        skipped += 1
        next
      end

      # Weight: random variation within ±1.5kg from base (one decimal place)
      weight = (base_weight + rand(-15..15) / 10.0).round(1)

      # Condition: integer 1-5 (weighted toward 3 and 4)
      condition = [1, 2, 3, 3, 3, 4, 4, 4, 5, 5].sample

      user.health_logs.create!(
        date:      date,
        weight:    weight,
        condition: condition,
        memo:      ""
      )
      created += 1
    end

    puts "Created: #{created} records / Skipped (existing): #{skipped} records"
  end
end
