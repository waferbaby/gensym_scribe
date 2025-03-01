require_relative "../../config/environment"

namespace :discord do
  task :register_commands do
    Rails.logger = Logger.new(STDOUT)

    Rails.logger.info("Registering commands from JSON config...")
    data = File.read(File.join(Rails.root, "config", "slash_commands.json"))
    raise "Unable to read JSON file" unless data.present?

    json = JSON.parse(data)

    client = Discord::Client.new(ENV["DISCORD_APP_ID"], ENV["DISCORD_BOT_TOKEN"])
    client.register_commands(json, 911511513263665172)

    Rails.logger.info("Done!")
  rescue StandardError => e
    Rails.logger.error("Failed to register commands: #{e}")
  end
end
