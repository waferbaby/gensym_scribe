class CreateDestinyItems < ActiveRecord::Migration[8.0]
  def change
    create_table :destiny_items do |t|
      t.string :name
      t.bigint :bungie_id
      t.string :screenshot_url
      t.timestamps
    end
  end
end
