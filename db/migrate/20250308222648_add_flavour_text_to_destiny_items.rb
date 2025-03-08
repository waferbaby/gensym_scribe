class AddFlavourTextToDestinyItems < ActiveRecord::Migration[8.0]
  def change
    add_column :destiny_items, :flavour_text, :string
  end
end
