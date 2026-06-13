# Adds reusable keyword/date filtering scopes for index search.
# Declare the keyword columns per model with `searchable_by :col, ...`.
module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def searchable_by(*columns)
      @searchable_columns = columns.map(&:to_s)
    end

    def searchable_columns
      @searchable_columns || []
    end
  end

  included do
    # Case-sensitive LIKE across the declared columns; no-op when query is blank.
    scope :keyword_search, ->(query) {
      next all if query.blank?

      cols = searchable_columns
      next all if cols.empty?

      term = "%#{query}%"
      where(cols.map { |c| "#{c} LIKE ?" }.join(" OR "), *Array.new(cols.size, term))
    }

    # Filter by exact date; no-op when value is blank.
    scope :on_date, ->(value) { value.present? ? where(date: value) : all }
  end
end
