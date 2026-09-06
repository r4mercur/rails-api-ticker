class CreateGameLineups < ActiveRecord::Migration[7.1]
  def change
    create_table :game_lineups do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.boolean :starting, default: false, null: false
      t.string :position

      t.timestamps
    end

    add_index :game_lineups, %i[game_id player_id], unique: true
  end
end
