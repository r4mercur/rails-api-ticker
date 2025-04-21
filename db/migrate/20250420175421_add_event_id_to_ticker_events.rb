class AddEventIdToTickerEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :ticker_events, :event_id, :integer
  end
end
