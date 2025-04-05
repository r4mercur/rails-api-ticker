class CreateTickerEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :ticker_events do |t|
      t.references :ticker, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true

      t.integer :event_type
      t.string :text
      t.timestamps
    end
  end
end
