class AddSummaryToDestinyItems < ActiveRecord::Migration[8.0]
  def change
    add_column :destiny_items, :summary, :string
  end
end
