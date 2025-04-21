class AddMinuteToTickerEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :ticker_events, :minute, :string
  end
end
