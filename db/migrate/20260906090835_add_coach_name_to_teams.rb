class AddCoachNameToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :coach_name, :string
  end
end
