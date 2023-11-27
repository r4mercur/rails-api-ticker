class Participation < ActiveRecord::Migration[7.1]
  def change
    create_table :participations do |t|
      t.references :team, null: false, foreign_key: true
      t.references :competition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
