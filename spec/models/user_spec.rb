require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Devise modules' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is invalid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many bids' do
      user = User.create!(email: 'test@example.com', password: 'password123')
      bid1 = Bid.create!(user: user, prediction: 'up', price: 1000, resolved: true)
      bid2 = Bid.create!(user: user, prediction: 'down', price: 1200, resolved: false)

      expect(user.bids).to include(bid1, bid2)
      expect(user.bids.count).to eq(2)
    end
  end

  describe '#can_guess?' do
    let(:user) { create(:user) }

    context 'when user has no unresolved bids' do
      it 'returns true' do
        create(:bid, user: user, resolved: true)
        expect(user.can_guess?).to be true
      end
    end

    context 'when user has unresolved bids' do
      it 'returns false' do
        create(:bid, user: user, resolved: false)
        expect(user.can_guess?).to be false
      end
    end
  end
end
