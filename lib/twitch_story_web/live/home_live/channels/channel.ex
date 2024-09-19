defmodule TwitchStoryWeb.HomeLive.Channels.Channel do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Channels.Channel
  alias TwitchStory.Twitch.Channels.Clip

  @impl true
  def mount(%{"broadcaster_id" => broadcaster_id}, _session, socket) do
    channel = Channel.get!(broadcaster_id)
    {:ok, schedule} = Api.schedule(broadcaster_id)

    socket
    |> assign(channel: channel)
    |> assign(schedule: schedule)
    |> assign(clips: Clip.broadcaster(broadcaster_id))
    |> then(fn socket -> {:ok, socket} end)
  end
end
