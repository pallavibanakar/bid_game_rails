require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe ResolveBidJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let!(:user) { create(:user, score: 0) }
  let!(:bid) { create(:bid, user: user, price: 1000, prediction: 'up', resolved: false) }
  let(:now) { Time.current }

  before do
    allow(BtcPriceService).to receive(:latest_price).and_return(2000)
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '#perform' do
    context 'when the bid is unresolved' do
      it 'resolves the bid and updates the user score' do
        ResolveBidJob.perform_now(bid.id)

        bid.reload
        user.reload

        expect(bid.resolved).to be true
        expect(bid.result).to eq(1)
        expect(bid.resolution_price).to eq(2000)
        expect(bid.resolved_at).to be_present
        expect(user.score).to eq(1)
      end
    end

    context 'when the bid is already resolved' do
      it 'does not perform any action' do
        bid.update(resolved: true, result: -1, resolution_price: 2050)

        ResolveBidJob.perform_now(bid.id)

        bid.reload

        expect(bid.resolved).to be true
        expect(bid.resolution_price).to eq(2050)
        expect(bid.result).to eq(-1)
      end
    end

    context 'when the BTC price is nil' do
      it 're-enqueues the job and logs a warning' do
        allow(BtcPriceService).to receive(:latest_price).and_return(nil)

        allow(Rails.logger).to receive(:warn)

        ResolveBidJob.perform_now(bid.id)

        expect(Rails.logger).to have_received(:warn).with('BTC price not available — re-enqueuing guess resolution')
        travel_to(now) do
          expect {
            ResolveBidJob.perform_now(bid.id)
          }.to have_enqueued_job(described_class)
               .with(bid.id)
               .at(be_within(1.second).of(now + 15.seconds))
        end
        expect(bid.resolved).to be false
      end
    end

    context 'when the bid price equals BTC price' do
      it 're-enqueues the job and logs a warning' do
        allow(BtcPriceService).to receive(:latest_price).and_return(bid.price)

        allow(Rails.logger).to receive(:warn)

        ResolveBidJob.perform_now(bid.id)

        expect(Rails.logger).to have_received(:warn).with('BTC price not available — re-enqueuing guess resolution')
        travel_to(now) do
          expect {
            ResolveBidJob.perform_now(bid.id)
          }.to have_enqueued_job(described_class)
               .with(bid.id)
               .at(be_within(1.second).of(now + 15.seconds))
        end
      end
    end

    context 'when an error occurs in the job' do
      it 'retries the job' do
        allow(BtcPriceService).to receive(:latest_price).and_raise(StandardError, 'Some error')

        travel_to(now) do
          expect {
            ResolveBidJob.perform_now(bid.id)
          }.to have_enqueued_job(described_class)
               .with(bid.id)
               .at(be_within(2.second).of(now + 10.seconds))
        end
      end
    end
  end
end
