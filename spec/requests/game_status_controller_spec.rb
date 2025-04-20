require 'rails_helper'

RSpec.describe 'GameStatus', type: :request do
  let(:user) { create(:user, score: 42) }
  let(:btc_price) { 27000.5 }

  before do
    allow(BtcPriceService).to receive(:latest_price).and_return(btc_price)
  end

  describe 'GET /game_status' do
    context 'when user is authenticated' do
      before do
        sign_in user
        get "/users/#{user.id}/game_status"
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns correct game status data' do
        json = JSON.parse(response.body)

        expect(json['score']).to eq(user.score)
        expect(json['can_guess']).to eq(true)
        expect(json['price']).to eq(btc_price)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get "/users/#{user.id}/game_status"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
