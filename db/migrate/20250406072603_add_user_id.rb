class AddUserId < ActiveRecord::Migration[7.1]
  def change
    add_column :tickers, :user_id, :integer, null: true
    add_column :ticker_events, :user_id, :integer, null: true
  end
end
