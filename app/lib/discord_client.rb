require "httpx"

class DiscordClient
  def initialize(app_id, bot_id)
    @app_id = app_id
    @bot_id = bot_id
  end

  def register_commands(payload, guild_id = nil)
    path =
      if guild_id.present?
        "/guilds/#{guild_id}/commands"
      else
        "/commands"
      end

    response = connection.post(path, json: payload)
    response.raise_for_status

    true
  end

  private

  def connection
    @connection ||= HTTPX.with(
      origin: "https://discord.com",
      base_path: "/api/v10/applications/#{@app_id}",
      headers: {
        authorization: "Bot #{@bot_id}",
        'user-agent': "Zavala Club Discord Bot (v0.1)"
      }
    )
  end
end
