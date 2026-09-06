class AddStatsToTickers < ActiveRecord::Migration[7.1]
  def change
    add_column :tickers, :possession_home, :integer, default: 0, null: false
    add_column :tickers, :possession_away, :integer, default: 0, null: false
    add_column :tickers, :shots_home, :integer, default: 0, null: false
    add_column :tickers, :shots_away, :integer, default: 0, null: false
    add_column :tickers, :shots_on_target_home, :integer, default: 0, null: false
    add_column :tickers, :shots_on_target_away, :integer, default: 0, null: false
    add_column :tickers, :corners_home, :integer, default: 0, null: false
    add_column :tickers, :corners_away, :integer, default: 0, null: false
    add_column :tickers, :fouls_home, :integer, default: 0, null: false
    add_column :tickers, :fouls_away, :integer, default: 0, null: false
  end
end
