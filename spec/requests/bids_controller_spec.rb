require 'rails_helper'

RSpec.describe 'Bids', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'POST /bids' do
    context 'when valid params are provided' do
      let(:valid_params) do
        {
          bid: {
            price: 1000,
            prediction: 'up'
          }
        }
      end

      context 'when user can guess' do
        before do
          allow(user).to receive(:can_guess?).and_return(true)
        end

        it 'creates a new bid and returns created status' do
          expect {
            post "/users/#{user.id}/bids", params: valid_params
          }.to change(Bid, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)['price']).to eq(1000)
          expect(JSON.parse(response.body)['prediction']).to eq('up')
        end

        it 'enqueues the ResolveBidJob to run after 60 seconds' do
          expect(ResolveBidJob).to receive(:set).with(wait: 60.seconds).and_return(double(perform_later: true))
          post "/users/#{user.id}/bids", params: valid_params
        end
      end

      context 'when user cannot guess' do
        before do
          allow(user).to receive(:can_guess?).and_return(false)
        end

        it 'does not create a bid and returns an error message' do
          expect {
            post "/users/#{user.id}/bids", params: valid_params
          }.not_to change(Bid, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['error']).to eq('Please wait for the last guess to be resolved')
        end
      end
    end

    context 'when invalid params are provided' do
      let(:invalid_params) do
        {
          bid: {
            price: nil, # Invalid price
            prediction: nil # Invalid prediction
          }
        }
      end

      it 'returns an error when price is missing' do
        post "/users/#{user.id}/bids", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Price can't be blank")
      end

      it 'returns an error when prediction is missing' do
        invalid_params[:bid][:price] = 1000
        invalid_params[:bid][:prediction] = nil

        post "/users/#{user.id}/bids", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Prediction can't be blank")
      end
    end
  end
end
