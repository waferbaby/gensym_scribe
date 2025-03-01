class DestinyItem < ApplicationRecord
  def self.search(name, limit: 10)
    where("lower(name) LIKE ?", sanitize_sql_like(name.downcase) + "%")
      .where.not(name: "")
      .limit(limit)
      .order(name: :asc)
      .pluck(:bungie_id, :name)
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
