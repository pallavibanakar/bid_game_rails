FactoryBot.define do
  factory :bid do
    association :user
    prediction { [ 'up', 'down' ].sample }
    price { rand(20_000..50_000) }
    resolved { false }
    resolved_at { Time.current.utc }
    result { [ -1, 1 ].sample }
    resolution_price { nil }
  end
end
