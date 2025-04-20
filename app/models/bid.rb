class Bid < ApplicationRecord
  belongs_to :user

  enum :prediction, { up: 1, down: -1 }
end
