class AddMoreColumnsToDestinyItems < ActiveRecord::Migration[8.0]
  def change
    add_column :destiny_items, :item_type, :integer
    add_column :destiny_items, :item_sub_type, :integer
    add_column :destiny_items, :class_type, :integer
    add_column :destiny_items, :lore_entry, :string
  end
end
