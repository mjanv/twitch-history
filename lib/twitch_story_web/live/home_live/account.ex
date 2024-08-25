defmodule TwitchStoryWeb.HomeLive.Account do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Auth.OauthToken
  alias TwitchStory.Twitch.Requests.Request

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    token = OauthToken.get(current_user)
    {:ok, requests} = Request.all(current_user.twitch_id)
    {:ok, events} = TwitchStory.EventStore.all(current_user.id, true)

    {:ok, assign(socket, requests: requests, events: events, token: token)}
  end
end
