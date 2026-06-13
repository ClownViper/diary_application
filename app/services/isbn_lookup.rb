require "net/http"
require "json"

# Looks up book metadata by ISBN. Tries OpenBD first (free, Japanese,
# no key), then falls back to Google Books (API key optional).
# Returns { title:, author:, thumbnail: } or nil when not found.
class IsbnLookup
  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 5

  def self.call(isbn)
    new(isbn).call
  end

  def initialize(isbn)
    @isbn = isbn
  end

  def call
    search_openbd || search_google_books
  end

  private

  # OpenBD: Japanese book database (free, no API key required)
  def search_openbd
    res = get_response(URI("https://api.openbd.jp/v1/get?isbn=#{@isbn}"))
    return nil unless res.is_a?(Net::HTTPSuccess)

    data = JSON.parse(res.body)
    return nil if data.blank? || data[0].nil?

    summary = data[0]["summary"]
    return nil if summary.blank? || summary["title"].blank?

    {
      title:     summary["title"],
      author:    summary["author"].presence,
      thumbnail: summary["cover"].presence
    }
  end

  # Google Books: international fallback (API key optional but recommended)
  def search_google_books
    uri = URI("https://www.googleapis.com/books/v1/volumes")
    params = { q: "isbn:#{@isbn}" }
    api_key = Rails.application.credentials.dig(:google_books, :api_key)
    params[:key] = api_key if api_key.present?
    uri.query = URI.encode_www_form(params)

    res = get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)

    data = JSON.parse(res.body)
    return nil if data["totalItems"].to_i == 0

    info      = data["items"][0]["volumeInfo"]
    thumbnail = info.dig("imageLinks", "thumbnail")&.sub("http://", "https://")

    {
      title:     info["title"],
      author:    info["authors"]&.join(", "),
      thumbnail: thumbnail
    }
  end

  # GET with explicit connection timeouts so a slow/unreachable API
  # cannot tie up a request thread indefinitely.
  def get_response(uri)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == "https",
                    open_timeout: OPEN_TIMEOUT,
                    read_timeout: READ_TIMEOUT) do |http|
      http.get(uri.request_uri)
    end
  end
end
