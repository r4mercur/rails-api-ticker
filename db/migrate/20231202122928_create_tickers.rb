class CreateTickers < ActiveRecord::Migration[7.1]
  def change
    create_table :tickers do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :date
      t.integer :goals_home, null: true
      t.integer :goals_away, null: true

      t.timestamps
    end
  end
end
