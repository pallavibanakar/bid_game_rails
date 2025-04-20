class AddNameAndScoreToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :score, :integer, default: 0, null: false
  end
end
