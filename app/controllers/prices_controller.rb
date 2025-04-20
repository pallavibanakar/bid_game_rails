class PricesController < ApplicationController
  before_action :authenticate_user!

  def index
    btc_price = BtcPriceService.latest_price(params["currency"] || "usd")

    if btc_price
      render json: { price: btc_price }, status: :ok
    else
      render json: { error: "Unable to fetch BTC price." }, status: :unprocessable_entity
    end
  end
end
