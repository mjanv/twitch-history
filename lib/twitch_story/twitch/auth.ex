defmodule TwitchStory.Twitch.Auth do
  @moduledoc false

  alias TwitchStory.Twitch.Auth.{Callback, OauthToken}

  defdelegate user_attrs(auth), to: Callback
  defdelegate oauth_token_attrs(auth), to: Callback

  # Oauth token
  defdelegate create_token(token, user), to: OauthToken, as: :create
end
