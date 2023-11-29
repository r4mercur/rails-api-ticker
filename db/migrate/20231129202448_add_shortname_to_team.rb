class AddShortnameToTeam < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :shortname, :string
  end
end
