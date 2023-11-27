class RemoveTypeFromCompetitions < ActiveRecord::Migration[7.1]
  def change
    remove_column :competitions, :type, :string
  end
end
