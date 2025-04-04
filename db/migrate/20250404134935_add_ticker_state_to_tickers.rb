class AddTickerStateToTickers < ActiveRecord::Migration[7.1]
  def change
    add_column :tickers, :ticker_state, :integer, default: 0, null: false
  end
end
