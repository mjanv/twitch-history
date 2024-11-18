defmodule TwitchStoryWeb.AccountsLive.Account do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Services.Renewal

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    {:ok, events} = TwitchStory.EventStore.all(current_user.id, true)
    {:ok, %{color: color}} = Renewal.sync_user(current_user)

    {:ok, assign(socket, events: events, color: color)}
  end
end
