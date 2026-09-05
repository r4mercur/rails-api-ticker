class AddPlayerReferencesToTickerEvents < ActiveRecord::Migration[7.1]
  def change
    add_reference :ticker_events, :player, null: true, foreign_key: true
    add_reference :ticker_events, :fk_player1, foreign_key: { to_table: :players }
    add_reference :ticker_events, :fk_player2, foreign_key: { to_table: :players }
  end
end
