defmodule TwitchStory.Twitch.Api.ChannelApi do
  @moduledoc false

  use TwitchStory.Twitch.Api.Client

  alias TwitchStory.Twitch.Api.AuthApi

  @type clip() :: %{
          required(:id) => String.t(),
          required(:video_id) => String.t(),
          required(:title) => String.t(),
          required(:created_at) => DateTime.t(),
          # Stats
          required(:duration) => float(),
          required(:view_count) => non_neg_integer(),
          # URLs
          required(:url) => String.t(),
          required(:embed_url) => String.t(),
          required(:thumbnail_url) => String.t(),
          # Broadcaster
          required(:broadcaster_id) => String.t(),
          required(:broadcaster_name) => String.t()
        }

  @spec reverse_search(String.t()) :: result(non_neg_integer(), :not_found | :invalid_request)
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
      {:ok, %Req.Response{status: 200, body: %{"data" => data, "template" => template}}} ->
        Enum.map(data, fn emote -> Map.put(emote, "template", template) end)

      _ ->
        []
    end
    |> Enum.map(fn emote ->
      emote
      |> Map.take([
        "id",
        "name",
        "tier",
        "emote_type",
        "emote_set_id",
        "format",
        "scale",
        "theme_mode",
        "template"
      ])
      |> Map.put("channel_id", broadcaster_id)
      |> Enum.map(fn
        {"id", code} -> {"emote_id", code}
        pair -> pair
      end)
      |> string_to_atom_keys()
    end)
    |> then(fn data -> {:ok, data} end)
  end

  def schedule(broadcaster_id) do
    AuthApi.get(url: "/helix/schedule?broadcaster_id=#{broadcaster_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => %{"segments" => nil}}}} -> []
      {:ok, %Req.Response{status: 200, body: %{"data" => %{"segments" => segments}}}} -> segments
      _ -> []
    end
    |> Enum.map(fn entry ->
      entry
      |> Enum.map(fn
        {"id", id} -> {"entry_id", id}
        {"start_time", nil} -> {"start_time", nil}
        {"start_time", t} -> {"start_time", t |> DateTime.from_iso8601() |> elem(1)}
        {"end_time", nil} -> {"end_time", nil}
        {"end_time", t} -> {"end_time", t |> DateTime.from_iso8601() |> elem(1)}
        {"category", nil} -> {"category", nil}
        {"category", %{"name" => name}} -> {"category", name}
        {"canceled_until", nil} -> {"is_canceled", false}
        {"canceled_until", _} -> {"is_canceled", true}
        pair -> pair
      end)
      |> Enum.into(%{})
      |> Map.take([
        "entry_id",
        "title",
        "start_time",
        "end_time",
        "is_recurring",
        "is_canceled",
        "category"
      ])
      |> string_to_atom_keys()
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

  defp users(broadcaster_id) do
    case AuthApi.get(url: "/helix/users?id=#{broadcaster_id}") do
      {:ok, %Req.Response{status: 200, body: %{"data" => [data | _]}}} ->
        {url, data} =
          Map.pop(Map.take(data, ["description", "profile_image_url"]), "profile_image_url")

        {:ok, Map.put(data, "thumbnail_url", url)}

      _ ->
        {:error, :not_found}
    end
  end

  @fields [
    "id",
    "video_id",
    "title",
    "created_at",
    "duration",
    "view_count",
    "url",
    "embed_url",
    "thumbnail_url",
    "broadcaster_id",
    "broadcaster_name"
  ]

  @doc "Get channel clips"
  @spec clips(String.t(), Keyword.t()) :: result([clip()], :not_found | :invalid_request)
  def clips(broadcaster_id, shift_opts \\ [day: -7]) do
    stop = DateTime.truncate(DateTime.utc_now(), :second)
    # WARNING: shift or shift_zone?
    start = DateTime.shift(stop, shift_opts)

    [
      url:
        "/helix/clips?broadcaster_id=#{broadcaster_id}&started_at=#{DateTime.to_iso8601(start)}&ended_at=#{DateTime.to_iso8601(stop)}"
    ]
    |> AuthApi.get()
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} ->
        data
        |> unwrap(@fields)
        |> as_date([:created_at])
        |> Enum.map(fn d ->
          d
          |> Enum.map(fn
            {:id, id} -> {:twitch_id, id}
            pair -> pair
          end)
          |> Enum.into(%{})
          |> nest_keys([:url, :thumbnail_url, :embed_url], :urls)
          |> nest_keys([:duration, :view_count], :stats)
        end)
        |> ok()

      {:ok, _} ->
        error(:not_found)

      {:error, _} ->
        error(:invalid_request)
    end
  end
end
