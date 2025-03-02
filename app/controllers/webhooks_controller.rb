class WebhooksController < ApplicationController
  before_action :validate_request

  def index
    response = case params[:type].to_i
    when Discord::Interaction::PING
      { type: Discord::Interaction::PONG }
    when Discord::Interaction::APPLICATION_COMMAND
      process_command(params["data"]&.dig("options").first)
    when Discord::Interaction::APPLICATION_COMMAND_AUTOCOMPLETE
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

    embed = case command.fetch(:name, false)
    when "lore"
      { title: item.name, description: item.lore_entry }
    when "screenshot"
      { title: item.name, image: { url: item.screenshot_url } }
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

    items = DestinyItem.search(query)
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
    verification_key = Ed25519::VerifyKey.new([ ENV["DISCORD_APP_PUBLIC_KEY"] ].pack("H*"))

    signature = request.headers["HTTP_X_SIGNATURE_ED25519"]
    timestamp = request.headers["HTTP_X_SIGNATURE_TIMESTAMP"]

    raise "Missing verification headers" unless signature.present? && timestamp.present?

    verification_key.verify([ signature ].pack("H*"), "#{timestamp}#{request.raw_post}")
  rescue StandardError => e
    Rails.logger.error("Failed to validate webhook request: #{e}")
    head :unauthorized
  end
end
