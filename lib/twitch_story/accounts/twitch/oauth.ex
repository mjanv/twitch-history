defmodule TwitchStory.Accounts.Twitch.OAuth do
  @moduledoc false

  alias Ueberauth.Auth

  def user_params(%Auth{uid: uid, provider: :twitch, info: %Auth.Info{email: email, image: image}}) do
    %{
      email: email,
      provider: "twitch",
      twitch_id: uid,
      twitch_avatar: image
    }
  end

  def user_tokens_params(%Auth{
        uid: uid,
        provider: :twitch,
        credentials: %Auth.Credentials{token: token, refresh_token: refresh_token, scopes: scopes}
      }) do
    %{
      user_id: uid,
      access_token: token,
      refresh_token: refresh_token,
      scopes: scopes
    }
  end
end
