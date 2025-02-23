require "discordrb"

class DiscordBot
  class << self
    def setup(token)
      engine = Discordrb::Bot.new(token: token, intents: [ :server_messages ])

      server_id = 911511513263665172
      description = "Look up information about Destiny items"

      engine.register_application_command(:zc, description, server_id: server_id) do |command|
        command.subcommand_group(:item, "Blah") do |group|
          group.subcommand("screenshot", "Find a screenshot of an item") do |subcommand|
            subcommand.string(:query, "Search for an item by name", required: true)
          end

          group.subcommand("lore", "Read the lore for an item") do |subcommand|
            subcommand.string(:query, "Search for an item by name", required: true)
          end
        end
      end

      engine.application_command(:zc).group(:item) do |group|
        group.subcommand("lore") do |event|
          Rails.logger.info("Got lore request: #{event}")

          event.respond(content: DestinyItem.last.name)
        end
      end

      engine.run(true)
    end
  end
end
