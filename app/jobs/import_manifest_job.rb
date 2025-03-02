class ImportManifestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    definitions = {
      items: Restiny::ManifestDefinition::INVENTORY_ITEM,
      lore: Restiny::ManifestDefinition::LORE
    }

    manifest = Rails.cache.fetch("ZavalaClubManifest-#{Time.now.strftime('%Y-%m-%d')}") do
      Restiny.download_manifest_json(definitions: definitions.values)
    end

    raise "Can't find items data" unless manifest.present?

    data = {}

    definitions.each do |name, definition|
      contents = File.read(manifest[definition])
      raise "Unable to read #{name} JSON" unless contents.present?

      data[name] = JSON.parse(contents)
    end

    data[:items]&.each do |bungie_id, payload|
      item = {
        bungie_id: payload["hash"].to_s,
        name: payload.dig("displayProperties", "name"),
        screenshot_url: payload["screenshot"],
        item_type: payload["itemType"],
        item_sub_type: payload["itemSubType"],
        class_type: payload["classTime"]
      }

      if data[:lore].key?(item[:bungie_id])
        item[:lore_entry] = data[:lore][item[:bungie_id]].dig("displayProperties", "description")
      end

      DestinyItem.upsert(item, unique_by: :bungie_id)
    end

    true
  rescue StandardError => e
    Rails.logger.error("Manifest import failed: #{e}")
  end
end
