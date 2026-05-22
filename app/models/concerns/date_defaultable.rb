# Shared concern: sets the date column default to today
# Include in any model with a date column (Diary, HealthLog, Expense, Schedule, etc.)
module DateDefaultable
  extend ActiveSupport::Concern

  included do
    after_initialize do
      self.date ||= Date.current
    end
  end
end
