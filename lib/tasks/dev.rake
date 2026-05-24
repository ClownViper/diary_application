namespace :dev do
  desc "体調ログのサンプルデータを今年1年分作成する（既存データはスキップ）"
  task seed_health_logs_year: :environment do
    email = ENV["EMAIL"]
    user = email.present? ? User.find_by!(email: email) : User.first

    abort "ユーザーが見つかりません" unless user

    puts "対象ユーザー: #{user.email}"

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

    puts "作成: #{created}件 / スキップ（既存）: #{skipped}件"
  end

  desc "体調ログのサンプルデータを1ヶ月分作成する（既存データはスキップ）"
  task seed_health_logs: :environment do
    # 対象ユーザーを指定（引数なしの場合は最初のユーザー）
    email = ENV["EMAIL"]
    user = email.present? ? User.find_by!(email: email) : User.first

    abort "ユーザーが見つかりません" unless user

    puts "対象ユーザー: #{user.email}"

    base_weight = ENV["WEIGHT"]&.to_f || 65.0  # 基準体重（環境変数で上書き可）
    today = Date.today
    start_date = today.beginning_of_month
    created = 0
    skipped = 0

    (start_date..today).each do |date|
      if user.health_logs.exists?(date: date)
        skipped += 1
        next
      end

      # 体重: 基準値からランダムに±1.5kg 以内で変動（小数第1位）
      weight = (base_weight + rand(-15..15) / 10.0).round(1)

      # 体調: 1〜5 の整数（3・4 が出やすいように重み付け）
      condition = [1, 2, 3, 3, 3, 4, 4, 4, 5, 5].sample

      user.health_logs.create!(
        date:      date,
        weight:    weight,
        condition: condition,
        memo:      ""
      )
      created += 1
    end

    puts "作成: #{created}件 / スキップ（既存）: #{skipped}件"
  end
end
