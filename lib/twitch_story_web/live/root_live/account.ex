defmodule TwitchStoryWeb.RootLive.Account do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Auth.OauthToken
  alias TwitchStory.Twitch.Requests.Request

  @impl true
  def mount(_params, _session, socket) do
    token = OauthToken.get(socket.assigns.current_user)
    {:ok, requests} = Request.all(socket.assigns.current_user.twitch_id)
    {:ok, assign(socket, requests: requests, token: token)}
  end
end
