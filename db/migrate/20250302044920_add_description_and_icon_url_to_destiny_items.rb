class AddDescriptionAndIconUrlToDestinyItems < ActiveRecord::Migration[8.0]
  def change
    add_column :destiny_items, :description, :string
    add_column :destiny_items, :icon_url, :string
  end
end
