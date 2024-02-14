defmodule TwitchStory.Twitch.Api do
  @moduledoc false

  @api Application.compile_env(:twitch_story, :twitch_api)

  def token do
    Req.new(base_url: @api[:id_api_url])
    |> Req.Request.put_headers([{"Content-Type", "application/x-www-form-urlencoded"}])
    |> Req.post(
      url: "/oauth2/token",
      params: [
        client_id: @api[:client_id],
        client_secret: @api[:client_secret],
        grant_type: "client_credentials"
      ]
    )
    |> case do
      {:ok,
       %Req.Response{
         status: 200,
         body: %{"token_type" => "bearer", "access_token" => access_token}
       }} ->
        access_token

      _ ->
        nil
    end
  end

  def emotes(broadcaster_id) do
    Req.new(base_url: @api[:api_url])
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/chat/emotes?broadcaster_id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      _ -> []
    end
    |> Enum.map(fn emote ->
      emote
      |> Map.put("channel_id", Integer.to_string(broadcaster_id))
      |> Map.take(["id", "name", "emote_set_id", "channel_id", "format", "scale", "theme_mode"])
    end)
  end

  def channel(broadcaster_id) do
    Map.merge(channels(broadcaster_id), users(broadcaster_id))
  end

  defp channels(broadcaster_id) do
    Req.new(base_url: "https://api.twitch.tv")
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/channels?broadcaster_id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [data | _]}}} ->
        Map.take(data, [
          "broadcaster_id",
          "broadcaster_login",
          "broadcaster_name",
          "broadcaster_language",
          "description",
          "tags"
        ])

      error ->
        error
    end
  end

  defp users(broadcaster_id) do
    Req.new(base_url: "https://api.twitch.tv")
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/users?id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [data | _]}}} ->
        Map.take(data, ["description", "profile_image_url"])

      error ->
        error
    end
  end
end
