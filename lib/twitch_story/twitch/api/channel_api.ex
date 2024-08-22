defmodule TwitchStory.Twitch.Api.ChannelApi do
  @moduledoc false

  alias TwitchStory.Twitch.Api.AuthApi

  def reverse_search(login) do
    AuthApi.get(url: "/helix/users?login=#{login}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => [%{"id" => id} | _]}}} ->
        {:ok, String.to_integer(id)}

      {:ok, _} ->
        {:error, :not_found}

      {:error, _} ->
        {:error, :invalid_request}
    end
  end

  def emotes(broadcaster_id) do
    AuthApi.get(url: "/helix/chat/emotes?broadcaster_id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} -> data
      _ -> []
    end
    |> Enum.map(fn emote ->
      emote
      |> Map.put("channel_id", Integer.to_string(broadcaster_id))
      |> Map.take(["id", "name", "emote_set_id", "channel_id", "format", "scale", "theme_mode"])
      |> Enum.map(fn
        {"id", code} -> {"emote_id", code}
        pair -> pair
      end)
      |> Enum.into(%{})
    end)
    |> then(fn data -> {:ok, data} end)
  end

  def channel(broadcaster_id) do
    with {:ok, channel} <- channels(broadcaster_id),
         {:ok, user} <- users(broadcaster_id) do
      {:ok, Map.merge(channel, user)}
    else
      {:error, error} -> {:error, error}
    end
  end

  @fields [
    "broadcaster_id",
    "broadcaster_login",
    "broadcaster_name",
    "broadcaster_language",
    "description",
    "tags"
  ]

  defp channels(broadcaster_id) do
    case AuthApi.get(url: "/helix/channels?broadcaster_id=#{broadcaster_id}") do
      {:ok, %Req.Response{status: 200, body: %{"data" => [data | _]}}} ->
        {:ok, Map.take(data, @fields)}

      _ ->
        {:error, :not_found}
    end
  end

  @fields ["description", "profile_image_url"]

  defp users(broadcaster_id) do
    case AuthApi.get(url: "/helix/users?id=#{broadcaster_id}") do
      {:ok, %Req.Response{status: 200, body: %{"data" => [data | _]}}} ->
        {url, data} = Map.pop(Map.take(data, @fields), "profile_image_url")
        {:ok, Map.put(data, "thumbnail_url", url)}

      _ ->
        {:error, :not_found}
    end
  end
end
