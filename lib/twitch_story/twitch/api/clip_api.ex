defmodule TwitchStory.Twitch.Api.ClipApi do
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
  @spec channel_clips(String.t()) :: result([clip()], :not_found | :invalid_request)
  def channel_clips(broadcaster_id) do
    [url: "/helix/clips?broadcaster_id=#{broadcaster_id}"]
    |> AuthApi.get()
    |> case do
      {:ok, %Req.Response{status: 200, body: %{"data" => data}}} ->
        data |> unwrap(@fields) |> as_date([:created_at]) |> ok()

      {:ok, _} ->
        error(:not_found)

      {:error, _} ->
        error(:invalid_request)
    end
  end
end
