class FixForeignKeysGames < ActiveRecord::Migration[7.1]
  def change
    drop_table :games
    create_table :games do |t|
      t.references :team_home, null: false, foreign_key: { to_table: :teams }
      t.references :team_away, null: false, foreign_key: { to_table: :teams }
      t.references :competition, null: false, foreign_key: true
      t.integer :goals_home, null: true
      t.integer :goals_away, null: true
      t.datetime :date
      t.string :location, null: true
      t.integer :match_day

      t.timestamps
    end
  end
end
