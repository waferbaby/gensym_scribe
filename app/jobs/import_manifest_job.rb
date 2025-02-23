class ImportManifestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    manifest = Rails.cache.fetch("ManifestInventoryItems-#{Time.now.strftime('%Y-%m-%d')}") do
      Restiny.download_manifest_json(definitions: [ Restiny::ManifestDefinition::INVENTORY_ITEM ])
    end

    raise "Can't find items data" unless manifest.present?

    path = manifest[Restiny::ManifestDefinition::INVENTORY_ITEM]
    contents = File.read(path)
    raise "Unable to read JSON" unless contents.present?

    JSON.parse(contents)&.each do |bungie_id, payload|
      item = {
        bungie_id: bungie_id,
        name: payload.dig("displayProperties", "name"),
        screenshot_url: payload["screenshot"]
      }

      DestinyItem.upsert(item, unique_by: :bungie_id)
    end
  rescue StandardError => e
    Rails.logger.error("Manifest import failed: #{e}")
  end
end
