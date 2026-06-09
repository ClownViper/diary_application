user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.name     = "テストユーザー"
  u.password = "password"
end
user.update!(password: "password")

# Reset demo data on every deploy
user.diaries.delete_all
user.health_logs.delete_all
user.expenses.delete_all
user.books.delete_all
user.schedules.delete_all
user.categories.delete_all

# Categories
cat_names = ["食費", "交通費", "娯楽", "日用品"]
categories = cat_names.map { |name| user.categories.create!(name: name) }

# Diaries (12 entries)
diary_titles = [
  "今日の出来事", "穏やかな一日", "忙しい一日", "散歩日和", "読書三昧",
  "友人と会った", "仕事が捗った", "久しぶりの外出", "在宅勤務", "早起きした",
  "雨の日", "充実した一日"
]
12.times do |i|
  date = Date.today - i
  user.diaries.create!(date: date, title: diary_titles[i], body: "#{date.strftime('%Y年%m月%d日')}の日記です。")
end

# Health logs (12 entries)
12.times do |i|
  date = Date.today - i
  user.health_logs.create!(
    date:        date,
    weight:      (60.0 + rand(-20..20) * 0.1).round(1),
    temperature: [nil, 36.2, 36.5, 36.8].sample,
    sleep_hours: (6.0 + rand(0..4) * 0.5).round(1),
    condition:   rand(3..5)
  )
end

# Expenses (12 entries)
expense_data = [
  { name: "スーパー",       amount: 2800, category: categories[0] },
  { name: "電車代",         amount: 540,  category: categories[1] },
  { name: "映画チケット",   amount: 1900, category: categories[2] },
  { name: "ドラッグストア", amount: 1200, category: categories[3] },
  { name: "ランチ",         amount: 950,  category: categories[0] },
  { name: "コーヒー",       amount: 480,  category: categories[0] },
  { name: "本",             amount: 1650, category: categories[2] },
  { name: "コンビニ",       amount: 630,  category: categories[0] },
  { name: "居酒屋",         amount: 3200, category: categories[2] },
  { name: "バス代",         amount: 220,  category: categories[1] },
  { name: "シャンプー",     amount: 880,  category: categories[3] },
  { name: "定食",           amount: 820,  category: categories[0] }
]
expense_data.each_with_index do |attrs, i|
  user.expenses.create!(name: attrs[:name], amount: attrs[:amount], date: Date.today - (i * 2), category: attrs[:category])
end

# Books (12 entries)
books_data = [
  { title: "リファクタリング",               author: "Martin Fowler",        status: :finished, started_on: 60.days.ago, finished_on: 45.days.ago },
  { title: "Clean Code",                      author: "Robert C. Martin",     status: :finished, started_on: 40.days.ago, finished_on: 25.days.ago },
  { title: "達人プログラマー",               author: "David Thomas",         status: :reading,  started_on: 10.days.ago },
  { title: "ゼロから作るDeep Learning",      author: "斎藤康毅",             status: :reading,  started_on: 5.days.ago  },
  { title: "プロを目指す人のためのRuby入門", author: "伊藤淳一",             status: :unread },
  { title: "オブジェクト指向設計実践ガイド", author: "Sandi Metz",           status: :finished, started_on: 80.days.ago, finished_on: 60.days.ago },
  { title: "SQLアンチパターン",              author: "Bill Karwin",          status: :unread },
  { title: "アジャイルサムライ",             author: "Jonathan Rasmusson",   status: :finished, started_on: 30.days.ago, finished_on: 15.days.ago },
  { title: "UNIXという考え方",               author: "Mike Gancarz",         status: :finished, started_on: 50.days.ago, finished_on: 38.days.ago },
  { title: "Design Patterns",                author: "Gang of Four",         status: :unread },
  { title: "マスタリングTCP/IP",             author: "竹下隆史 他",          status: :unread },
  { title: "エンジニアのための時間管理術",   author: "Thomas A. Limoncelli", status: :unread }
]
books_data.each do |attrs|
  user.books.create!(attrs)
end

# Schedules (6 entries: upcoming and past)
[
  { title: "チームミーティング",   offset: 1  },
  { title: "歯医者",               offset: 5  },
  { title: "プロジェクト締め切り", offset: 10 },
  { title: "週次レビュー",         offset: -1 },
  { title: "1on1",                 offset: -3 },
  { title: "スプリント振り返り",   offset: -7 }
].each do |attrs|
  user.schedules.create!(title: attrs[:title], date: Date.today + attrs[:offset], start_time: "10:00", end_time: "11:00")
end

puts "Seed done. Login: test@example.com / password"
