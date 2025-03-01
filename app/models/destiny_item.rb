class DestinyItem < ApplicationRecord
  def self.search(name)
    where("lower(name) LIKE ?", "%" + sanitize_sql_like(name.downcase) + "%")
      .limit(10)
      .order(name: :asc)
      .pluck(:id, :name)
  end

  def screenshot_url
    url = read_attribute(:screenshot_url)
    return "" unless url.present?

    "https://bungie.net#{url}"
  end

  def as_json(options = {})
    super(options).except("id", "created_at", "updated_at")
  end
end
