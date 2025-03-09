module Destiny
  class SeasonalAct < ApplicationRecord
    belongs_to :season, class_name: "Destiny::Season"
  end
end
