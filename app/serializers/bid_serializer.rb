class BidSerializer
  include JSONAPI::Serializer
  attributes :id, :price, :user_id, :prediction, :bid_at, :resolved
end
