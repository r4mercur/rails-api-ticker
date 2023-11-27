class Game < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.references :competition, null: false, foreign_key: true
      t.references :team_home, null: false, foreign_key: true
      t.references :team_away, null: false, foreign_key: true
      t.integer :team_home_score
      t.integer :team_away_score
      t.integer :match_day
      t.datetime :date
      t.string :location

      t.timestamps
    end
  end
end
