class AddPublicSlugToTickers < ActiveRecord::Migration[7.1]
  def change
    add_column :tickers, :public_slug, :string
    add_index :tickers, :public_slug, unique: true
  end
end
