require_relative "../../config/environment"

namespace :discord do
  task :register_commands do
    Rails.logger = Logger.new(STDOUT)

    Rails.logger.info("Registering commands from JSON config...")
    data = File.read(File.join(Rails.root, "config", "slash_commands.json"))
    raise "Unable to read JSON file" unless data.present?

    client = Rancour::Client.new(app_id: ENV["DISCORD_APP_ID"], bot_token: ENV["DISCORD_BOT_TOKEN"])
    client.register_application_commands(JSON.parse(data))

    Rails.logger.info("Done!")
  rescue StandardError => e
    Rails.logger.error("Failed to register commands: #{e}")
  end
end
