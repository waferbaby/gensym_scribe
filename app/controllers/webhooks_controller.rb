require "rancour"

class WebhooksController < ApplicationController
  BUNGIE_URL = "https://bungie.com/"

  before_action :validate_request

  def index
    response = case params[:type].to_i
    when Rancour::Interaction::PING
      { type: 1 }
    when Rancour::Interaction::APPLICATION_COMMAND
      process_command(params["data"]&.dig("options").first)
    when Rancour::Interaction::APPLICATION_COMMAND_AUTOCOMPLETE
      process_autocomplete_command(params)
    end

    render json: response and return if response.present?

    head :no_content
  end

  private

  def process_command(command)
    raise "Unknown command" unless command.present?

    bungie_id = command[:options].first[:value]
    item = DestinyItem.find_by(bungie_id: bungie_id)
    raise "Unknown item" unless item.present?

    embed = case command.fetch(:name, false)
    when "lore"
      { title: item.name, description: item.lore_entry }.tap do |entry|
        entry[:thumbnail] = { url: BUNGIE_URL + item.icon_url, width: 96, height: 96 } if item.icon_url.present?
      end
    when "screenshot"
      { title: item.name, description: item.flavour_text, image: { url: BUNGIE_URL + item.screenshot_url, width: 1920, height: 1080 } }
    end

    unless embed.nil?
      embed[:url] = "https://ishtar-collective.net/items/#{item.bungie_id}"
    end

    {
      type: 4,
      data: {
        tts: false,
        embeds: [ embed ],
        allowed_mentions: { parse: [] }
      }
    }
  end

  def process_autocomplete_command(command)
    query = command.dig(:data, :options)&.first.dig(:options).select { |option| option[:focused] == true }&.first.dig(:value)

    items = DestinyItem.search(query, limit: 20)
            .with_lore
            .with_screenshot
            .pluck(:bungie_id, :name)

    choices =
      if items.present?
        items.map { |bungie_id, name| { name: name, value: bungie_id.to_s } }
      else
        []
      end

    {
      type: 8,
      data: {
        choices: choices
      }
    }
  end

  def validate_request
    Rancour::Webhook.validate_request(
      public_key: ENV["DISCORD_APP_PUBLIC_KEY"],
      body: request.raw_post,
      signature: request.headers["HTTP_X_SIGNATURE_ED25519"],
      timestamp: request.headers["HTTP_X_SIGNATURE_TIMESTAMP"]
    )
  rescue StandardError => e
    Rails.logger.error("Failed to validate webhook request: #{e}")
    head :unauthorized
  end
end
