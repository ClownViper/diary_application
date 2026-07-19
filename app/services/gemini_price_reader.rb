require "net/http"

# Reads the printed price (e.g. "定価：本体1,600円＋税") from a photo of a
# book's back cover and returns the tax-included price in yen.
# Bibliographic APIs often carry stale or missing price data, so the printed
# price on the actual book is preferred. Returns nil when the API key is not
# configured or the price cannot be read; callers fall back to the API price.
class GeminiPriceReader
  MODEL        = "gemini-2.5-flash-lite".freeze
  OPEN_TIMEOUT = 10
  READ_TIMEOUT = 30
  TAX_RATE     = 1.10

  PROMPT = <<~PROMPT.freeze
    この画像は本の裏表紙（バーコード付近）の写真です。
    価格表記（例:「定価：本体1,600円＋税」「定価1,760円（税込）」）を探して抽出してください。
    - price: 表記されている金額の数値。価格表記が見つからなければ null
    - tax_included: 表記が税込価格なら true、本体価格（税抜）なら false、判別できなければ null
  PROMPT

  RESPONSE_SCHEMA = {
    type: "object",
    properties: {
      price:        { type: "integer", nullable: true },
      tax_included: { type: "boolean", nullable: true }
    }
  }.freeze

  def self.api_key
    ENV["GEMINI_API_KEY"].presence || Rails.application.credentials.dig(:gemini, :api_key)
  end

  def self.configured?
    api_key.present?
  end

  def initialize(base64_image)
    @base64_image = base64_image
  end

  # Tax-included price in yen (Integer) or nil
  def call
    return nil unless self.class.configured?

    normalize(extract_fields)
  rescue StandardError => e
    Rails.logger.warn("GeminiPriceReader failed: #{e.class}: #{e.message}")
    nil
  end

  private

  def extract_fields
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{MODEL}:generateContent")
    req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json",
                                   "x-goog-api-key" => self.class.api_key)
    req.body = request_body.to_json
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                          open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) { |http| http.request(req) }
    raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    text = JSON.parse(res.body).dig("candidates", 0, "content", "parts", 0, "text")
    JSON.parse(text.to_s)
  end

  def request_body
    {
      contents: [ { parts: [
        { text: PROMPT },
        { inline_data: { mime_type: "image/jpeg", data: @base64_image } }
      ] } ],
      generationConfig: {
        response_mime_type: "application/json",
        response_schema: RESPONSE_SCHEMA
      }
    }
  end

  # Never trust raw LLM output: coerce to integer, validate the range, and
  # convert tax-exclusive prices to tax-included.
  def normalize(fields)
    price = fields["price"].to_s.gsub(/[^\d]/, "").to_i
    return nil unless price.between?(100, 100_000)

    fields["tax_included"] == false ? (price * TAX_RATE).round : price
  end
end
