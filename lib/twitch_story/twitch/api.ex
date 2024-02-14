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

  def find_broadcaster_id(login) do
    Req.new(base_url: "https://api.twitch.tv")
    |> Req.Request.put_headers([
      {"Authorization", "Bearer #{token()}"},
      {"Client-Id", @api[:client_id]}
    ])
    |> Req.get(url: "/helix/users?login=#{login}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [%{"id" => id} | _]}}} ->
        {:ok, String.to_integer(id)}

      _ ->
        {:error, :not_found}
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
    |> then(fn data -> {:ok, data} end)
  end

  def channel(broadcaster_id) do
    with {:ok, channel} <- channels(broadcaster_id),
         {:ok, user} <- users(broadcaster_id) do
      {:ok, Map.merge(channel, user)}
    else
      {:error, :not_found} -> {:error, :not_found}
    end
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
        data
        |> Map.take([
          "broadcaster_id",
          "broadcaster_login",
          "broadcaster_name",
          "broadcaster_language",
          "description",
          "tags"
        ])
        |> then(fn data -> {:ok, data} end)

      _ ->
        {:error, :not_found}
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
        data = Map.take(data, ["description", "profile_image_url"])
        data = Map.put(data, "thumbnail_url", data["profile_image_url"])
        data = Map.delete(data, "profile_image_url")
        {:ok, data}

      _ ->
        {:error, :not_found}
    end
  end
end
