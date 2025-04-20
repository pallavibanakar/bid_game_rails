class BidsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = current_user || User.find_by(id: params[:id])
    if user.can_guess?
      bid = user.bids.create(create_params)
      if bid
        ResolveBidJob.set(wait: 60.seconds).perform_later(bid.id)
        render json: bid, status: :created
      else
        render json: { error: "Something went wrong, Please try again" }, status: :unprocessable_entity
      end
    else
      render json: {error: "Please wait for the last guess to be resolved"}, status: :unprocessable_entity
    end
  end

  protected

  def create_params
    params.require(:bid).permit(:price, :prediction).merge(bid_at: Time.current.utc)
  end
end
