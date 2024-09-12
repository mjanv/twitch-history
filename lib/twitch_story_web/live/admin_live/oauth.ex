defmodule TwitchStoryWeb.AdminLive.Oauth do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Accounts.UserToken
  alias TwitchStory.Twitch.Auth.OauthToken

  @impl true
  def mount(_params, _session, socket) do
    user_tokens = UserToken.all()
    oauth_tokens = OauthToken.all()

    {:ok, assign(socket, user_tokens: user_tokens, oauth_tokens: oauth_tokens)}
  end
end
