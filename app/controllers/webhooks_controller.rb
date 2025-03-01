class WebhooksController < ApplicationController
  before_action :validate_request

  def index
    case params[:type].to_i
    when Discord::Interaction::PING
      render json: { type: Discord::Interaction::PONG }
    when Discord::Interaction::APPLICATION_COMMAND
      process_command(params["data"]&.dig("options").first)
    when Discord::Interaction::APPLICATION_COMMAND_AUTOCOMPLETE
      process_autocomplete_command(params)
    else
      head :no_content
    end
  end

  private

  def process_command(command)
    raise "Unknown command" unless command.present?

    case command.fetch(:name, false)
    when "lore"
        message = "Indeed."
    when "screenshot"
        message = "Nice."
    end

    response = {
      type: 4,
      data: {
        tts: false,
        content: message,
        allowed_mentions: { parse: [] }
      }
    }

    render json: response
  end

  def process_autocomplete_command(command)
    query = command.dig(:data, :options)&.first.dig(:options).select { |option| option[:focused] == true }&.first.dig(:value)

    items = DestinyItem.search(query)

    choices =
      if items.present?
        items.map { |id, name| { name: name, value: id.to_s } }
      else
        []
      end

    response = {
      type: 8,
      data: {
        choices: choices
      }
    }

    render json: response
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
