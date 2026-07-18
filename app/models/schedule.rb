# Schedule model
class Schedule < ApplicationRecord
  include DateDefaultable
  include Searchable

  searchable_by :title, :memo

  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :memo, length: { maximum: 200 }

  # start_time is a timezone-aware :time column, so values are stored as UTC
  # wall-clock and a plain ORDER BY start_time sorts local mornings after
  # evenings (e.g. JST 08:00 is stored as 23:00). Order by the local
  # wall-clock instead; Postgres `time + interval` wraps within 24h.
  scope :by_start_time, -> {
    offset_hours = Time.zone.utc_offset / 3600
    order(Arel.sql("start_time + interval '#{offset_hours.to_i} hours'"))
  }
end
