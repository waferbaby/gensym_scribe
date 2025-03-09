class DestinySeason < ApplicationRecord
  has_many :acts, class_name: "DestinySeasonalAct", foreign_key: :season_id
end
