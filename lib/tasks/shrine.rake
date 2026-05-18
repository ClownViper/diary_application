namespace :shrine do
  desc "日記の画像設定を確認（ID=4 なら ID=4 bin/rails shrine:diary）"
  task diary: :environment do
    diary = Diary.find(ENV.fetch("ID", 1))
    puts "Diary ##{diary.id} #{diary.title}"
    puts "  image_data present?: #{diary.image_data.present?}"
    puts "  image present?:       #{diary.image.present?}"
    puts "  image_url:            #{diary.image&.url || '(なし)'}"
    puts "  Supabase configured?: #{ENV['SUPABASE_ENDPOINT'].present?}"
  end
end
