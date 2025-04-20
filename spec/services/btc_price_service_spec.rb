require 'rails_helper'
require 'net/http'

RSpec.describe BtcPriceService, type: :service do
  describe '.latest_price' do
    let(:currency) { 'USD' }
    let(:cache_key) { "btc_price_#{currency.downcase}" }

    before do
      allow(Rails.cache).to receive(:read).and_return(nil)
    end

    context 'when the price is fetched successfully' do
      let(:response_body) { { "data" => { "amount" => "50000" } }.to_json }

      before do
        allow(Net::HTTP).to receive(:start).and_yield(double('http', request: double('response', body: response_body, is_a?: true)))
      end

      it 'returns the BTC price' do
        price = BtcPriceService.latest_price(currency)
        expect(price).to eq(50000.0)
      end

      it 'caches the fetched price' do
        expect(Rails.cache).to receive(:write).with(cache_key, 50000.0, expires_in: 30.seconds)
        BtcPriceService.latest_price(currency)
      end
    end

    context 'when the price fetch fails (non-2xx response)' do
      before do
        allow(Net::HTTP).to receive(:start).and_yield(double('http', request: double('response', body: "", is_a?: false, code: '500', message: 'Internal Server Error')))
      end

      it 'logs the failure and returns nil' do
        expect(Rails.logger).to receive(:warn).with(/Coinbase BTC fetch failed/)
        price = BtcPriceService.latest_price(currency)
        expect(price).to be_nil
      end
    end

    context 'when an exception occurs during the fetch' do
      before do
        allow(Net::HTTP).to receive(:start).and_raise(StandardError.new('Network error'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Coinbase BTC fetch error/)
        price = BtcPriceService.latest_price(currency)
        expect(price).to be_nil
      end
    end

    context 'when the price is already cached' do
      before do
        allow(Rails.cache).to receive(:read).and_return(50000.0)
      end

      it 'returns the cached price' do
        price = BtcPriceService.latest_price(currency)
        expect(price).to eq(50000.0)
      end

      it 'does not call the external service if the price is cached' do
        expect(Net::HTTP).not_to receive(:start)
        BtcPriceService.latest_price(currency)
      end
    end
  end
end
