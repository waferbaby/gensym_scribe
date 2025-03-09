module Destiny
  class Season < ApplicationRecord
    has_many :acts, class_name: "DestinySeasonalAct", foreign_key: :season_id

    def self.search(name, limit: 10)
      where("lower(name) LIKE ?", "%" + sanitize_sql_like(name.downcase) + "%")
        .limit(limit)
        .order(start_date: :asc)
    end
  end
end
