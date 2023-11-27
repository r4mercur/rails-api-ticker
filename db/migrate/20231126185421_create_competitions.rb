class CreateCompetitions < ActiveRecord::Migration[7.1]
  def change
    create_table :competitions do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
