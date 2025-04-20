class GameStatusController < ApplicationController
  before_action :authenticate_user!

  def show
    user = current_user
    btc_price = BtcPriceService.latest_price

    render json: { score: user.score, can_guess: user.can_guess?, price: btc_price  },
           status: :ok, serializer: GameStatusSerializer
  end
end
