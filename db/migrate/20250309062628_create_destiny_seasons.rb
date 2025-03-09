class CreateDestinySeasons < ActiveRecord::Migration[8.0]
  def change
    create_table :destiny_seasons do |t|
      t.bigint :bungie_id
      t.string :name
      t.string :description
      t.integer :number
      t.datetime :start_date
      t.datetime :end_date
      t.string :background_image_url
      t.string :icon_url
      t.timestamps
    end
  end
end
