module Destiny
  class SeasonalAct < ApplicationRecord
    belongs_to :season, class_name: "DestinySeason"
  end
end
