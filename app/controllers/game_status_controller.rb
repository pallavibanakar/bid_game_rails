class GameStatusController < ApplicationController
  before_action :authenticate_user!

  def show
    user = current_user
    btc_price = BtcPriceService.latest_price
    last_bid = user.bids.order(created_at: :asc).last
    if last_bid && !last_bid.resolved
      seconds_since_bid = Time.current - last_bid.bid_at
      timer = [60 - seconds_since_bid.to_i, 0].max
    end

    render json: { score: user.reload.score, can_guess: user.can_guess?, price: btc_price, timer: timer || 0, result: last_bid&.result  },
           status: :ok, serializer: GameStatusSerializer
  end
end
