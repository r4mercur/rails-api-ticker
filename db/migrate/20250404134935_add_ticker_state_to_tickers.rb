class AddTickerStateToTickers < ActiveRecord::Migration[7.1]
  def change
    add_column :tickers, :ticker_state, :integer
  end
end
