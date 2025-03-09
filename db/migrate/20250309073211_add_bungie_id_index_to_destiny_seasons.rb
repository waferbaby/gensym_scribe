class AddBungieIdIndexToDestinySeasons < ActiveRecord::Migration[8.0]
  def change
    add_index :destiny_seasons, :bungie_id, unique: true
  end
end
