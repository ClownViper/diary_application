namespace :shrine do
  desc "Inspect diary image attachment (usage: ID=1 bin/rails shrine:diary)"
  task diary: :environment do
    diary = Diary.find(ENV.fetch("ID", 1))
    puts "Diary ##{diary.id} #{diary.title}"
    puts "  image_data present?: #{diary.image_data.present?}"
    puts "  image present?:       #{diary.image.present?}"
    puts "  image_url:            #{diary.image&.url || '(なし)'}"
    puts "  Supabase configured?: #{ENV['SUPABASE_ENDPOINT'].present?}"
  end
end
