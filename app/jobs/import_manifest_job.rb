class ImportManifestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    definitions = {
      items: Restiny::ManifestDefinition::INVENTORY_ITEM,
      lore: Restiny::ManifestDefinition::LORE,
      seasons: Restiny::ManifestDefinition::SEASON
    }

    manifest = Rails.cache.fetch("D2-Manifest-#{Time.now.strftime('%Y-%m-%d')}") do
      Restiny.download_manifest_json(definitions: definitions.values)
    end

    raise "Can't find manifest data" unless manifest.present?

    data = {}

    definitions.each do |name, definition|
      contents = File.read(manifest[definition])
      raise "Unable to read #{name} JSON" unless contents.present?

      data[name] = JSON.parse(contents)
    end

    data[:seasons]&.each do |bungie_id, payload|
      display_properties = payload["displayProperties"]
      next unless display_properties["name"].present?

      season = {
        bungie_id: payload["hash"].to_s,
        description: display_properties["description"],
        name: display_properties["name"],
        start_date: payload["startDate"],
        end_date: payload["endDate"],
        background_image_url: payload["backgroundImagePath"]
      }

      season[:icon_url] = display_properties["icon"] if display_properties["hasIcon"]

      Destiny::Season.upsert(season, unique_by: :bungie_id)

      if payload["acts"].present?
        season_id = Destiny::Season.find_by(bungie_id: payload["hash"])&.id
        next unless season_id.present?

        position = 1

        payload["acts"].each do |act_payload|
          act = {
            season_id: season_id,
            name: act_payload["displayName"],
            start_date: act_payload["startTime"],
            position: position,
            ranks: act_payload["rankCount"]
          }

          Destiny::SeasonalAct.upsert(act, unique_by: %i[season_id position])

          position += 1
        end
      end
    end

    data[:items]&.each do |bungie_id, payload|
      display_properties = payload["displayProperties"]

      item = {
        bungie_id: payload["hash"].to_s,
        class_type: payload["classType"],
        description: display_properties["description"],
        flavour_text: payload["flavorText"],
        summary: payload["itemTypeAndTierDisplayName"],
        item_sub_type: payload["itemSubType"],
        item_type: payload["itemType"],
        name: display_properties["name"],
        screenshot_url: payload["screenshot"],
        tier_type: payload.dig("inventory", "tierType")
      }

      item[:icon_url] = display_properties["icon"] if display_properties["hasIcon"]

      lore_id = (payload["loreHash"] || bungie_id).to_s

      if data[:lore].key?(lore_id)
        item[:lore_entry] = data[:lore][lore_id].dig("displayProperties", "description")
      end

      Destiny::Item.upsert(item, unique_by: :bungie_id)
    end

    true
  rescue StandardError => e
    Rails.logger.error("Manifest import failed: #{e}")
  end
end
