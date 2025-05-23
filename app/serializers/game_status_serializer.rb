class GameStatusSerializer
  include JSONAPI::Serializer
  attributes :score, :can_guess, :btc_price, :result, :timer

  def score
    object[:score]
  end

  def can_guess
    object[:can_guess]
  end

  def btc_price
    object[:btc_price]
  end

  def result
    object[:result]
  end

  def timer
    object[:timer]
  end
end
