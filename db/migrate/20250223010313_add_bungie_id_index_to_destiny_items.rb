class AddBungieIdIndexToDestinyItems < ActiveRecord::Migration[8.0]
  def change
    add_index :destiny_items, :bungie_id, unique: true
  end
end
