class ImportManifestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    definitions = {
      items: Restiny::ManifestDefinition::INVENTORY_ITEM,
      lore: Restiny::ManifestDefinition::LORE
    }

    manifest = Rails.cache.fetch("D2Manifest-#{Time.now.strftime('%Y-%m-%d')}") do
      Restiny.download_manifest_json(definitions: definitions.values)
    end

    raise "Can't find manifest data" unless manifest.present?

    data = {}

    definitions.each do |name, definition|
      contents = File.read(manifest[definition])
      raise "Unable to read #{name} JSON" unless contents.present?

      data[name] = JSON.parse(contents)
    end

    data[:items]&.each do |bungie_id, payload|
      display_properties = payload["displayProperties"]

      item = {
        bungie_id: payload["hash"].to_s,
        class_type: payload["classType"],
        description: display_properties["description"],
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

      DestinyItem.upsert(item, unique_by: :bungie_id)
    end

    true
  rescue StandardError => e
    Rails.logger.error("Manifest import failed: #{e}")
  end
end
