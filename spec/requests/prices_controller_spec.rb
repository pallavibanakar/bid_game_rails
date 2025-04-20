require 'rails_helper'

RSpec.describe "Prices", type: :request do
  let(:currency) { 'usd' }
  let(:user) { create(:user, score: 42) }

  before do
    sign_in user
  end


  describe 'GET /prices' do
    context 'when the price is successfully fetched' do
      before do
        allow(BtcPriceService).to receive(:latest_price).with(currency).and_return(50000)
        get prices_path(currency: currency)
      end

      it 'returns the correct status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the BTC price in the response body' do
        json = JSON.parse(response.body)
        expect(json['price']).to eq(50000)
      end
    end

    context 'when the price cannot be fetched' do
      before do
        allow(BtcPriceService).to receive(:latest_price).with(currency).and_return(nil)
        get prices_path(currency: currency)
      end

      it 'returns the correct status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an error message in the response body' do
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Unable to fetch BTC price.')
      end
    end

    context 'when currency parameter is missing' do
      before do
        allow(BtcPriceService).to receive(:latest_price).with('usd').and_return(50000)
        get prices_path
      end

      it 'fetches the BTC price for USD by default' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['price']).to eq(50000)
      end
    end
  end
end
