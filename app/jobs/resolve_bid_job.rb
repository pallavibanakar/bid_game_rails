class ResolveBidJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 10.seconds, attempts: 3

  def perform(bid_id)
    bid = Bid.find_by(id: bid_id)
    user = bid.user
    return if !bid || bid&.resolved

    btc_price = BtcPriceService.latest_price
    if btc_price.nil? || btc_price == bid.price
      Rails.logger.warn("BTC price not available — re-enqueuing guess resolution")
      self.class.set(wait: 15.seconds).perform_later(bid_id)
      return
    end

    predict_result =  (btc_price - bid.price).positive? ?  "up" : "down"
    bid_result = (predict_result == bid.prediction) ? 1 : -1

    bid.update(
      result: bid_result,
      resolved: true,
      resolution_price: btc_price,
      resolved_at: Time.current.utc
    )
    user.update(
      score: user.score + bid_result
    )

    Rails.logger.info "Resolved BTC guesses at #{Time.current}"
  rescue => e
    Rails.logger.error "ResolveBidJob failed: #{e.class} - #{e.message}"
    raise e
  end
end
