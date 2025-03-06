require_relative "../../config/environment"

namespace :discord do
  task :prepare_client do
    Rails.logger = Logger.new(STDOUT)
    Rancour::Client.new(app_id: ENV["DISCORD_APP_ID"], bot_token: ENV["DISCORD_BOT_TOKEN"])
  end

  task :register_commands do
    client = Rake::Task["discord:prepare_client"].invoke[0].call

    Rails.logger.info("Registering commands from JSON config...")
    data = File.read(File.join(Rails.root, "config", "slash_commands.json"))
    raise "Unable to read JSON file" unless data.present?

    client.register_application_commands(JSON.parse(data), guild_id: 257440210810437633)

    Rails.logger.info("Done!")
  rescue StandardError => e
    Rails.logger.error("Failed to register commands: #{e}")
  end

  task :delete_commands do
    client = Rake::Task["discord:prepare_client"].invoke[0].call

    command_ids = client.fetch_application_commands&.map { |command| command["id"] }

    if command_ids.nil? || command_ids.empty?
      Rails.logger.info("No commands found")
    else
      command_ids.each { |command_id| client.delete_application_command(command_id) }
    end
  rescue StandardError => e
    Rails.logger.error("Failed to delete commands: #{e}")
  end
end
