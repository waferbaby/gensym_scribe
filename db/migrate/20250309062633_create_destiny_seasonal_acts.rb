class CreateDestinySeasonalActs < ActiveRecord::Migration[8.0]
  def change
    create_table :destiny_seasonal_acts do |t|
      t.bigint :act_id
      t.integer :position
      t.integer :ranks
      t.string :name
      t.datetime :start_date
      t.timestamps
      t.index [ :act_id, :position ]
    end
  end
end
