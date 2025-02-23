class ChangeScreenshotUrlDefaultInBungieItems < ActiveRecord::Migration[8.0]
  def change
    change_column_default :destiny_items, :screenshot_url, from: nil, to: ''
  end
end
