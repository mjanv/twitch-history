defmodule TwitchStoryWeb.HomeLive.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Services.Renewal

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    {:ok, %{channels: channels}} = Renewal.sync_user(current_user)

    {:ok, assign(socket, channels: channels)}
  end
end
