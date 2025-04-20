require "net/http"
require "uri"
require "json"

class BtcPriceService
  BASE_URL = "https://api.coinbase.com/v2/prices"

  def self.latest_price(currency = "USD")
    cache_key = "btc_price_#{currency.downcase}"

    cached_price = Rails.cache.read(cache_key)
    return cached_price if cached_price.present?

    uri = URI("#{BASE_URL}/BTC-#{currency}/spot")

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Get.new(uri)
      req["Accept"] = "application/json"
      http.request(req)
    end

    if response.is_a?(Net::HTTPSuccess)
      body = JSON.parse(response.body)
      price = body.dig("data", "amount")&.to_f

      Rails.cache.write(cache_key, price, expires_in: 30.seconds) if price.present?

      price
    else
      Rails.logger.warn("Coinbase BTC fetch failed: #{response.code} #{response.message}")
      nil
    end
  rescue => e
    Rails.logger.error("Coinbase BTC fetch error: #{e.class} - #{e.message}")
    nil
  end
end
