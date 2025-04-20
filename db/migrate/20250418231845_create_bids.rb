class CreateBids < ActiveRecord::Migration[8.0]
  def change
    create_table :bids do |t|
      t.references  :user, null: false
      t.integer     :prediction, null: false
      t.float       :price, null: false
      t.float       :resolution_price, null: true
      t.boolean     :resolved, default: false
      t.integer     :result

      t.datetime :bid_at
      t.datetime :resolved_at
      t.timestamps
    end
  end
end
