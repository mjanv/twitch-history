defmodule TwitchStoryWeb.AdminLive.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Channels.Channel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, channels: Channel.all())}
  end
end
