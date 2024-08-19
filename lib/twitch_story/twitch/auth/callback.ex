defmodule TwitchStory.Twitch.Auth.Callback do
  @moduledoc false

  def user_attrs(%Ueberauth.Auth{
        uid: uid,
        provider: :twitch,
        info: %Ueberauth.Auth.Info{name: name, email: email, image: image}
      }) do
    %{
      name: name,
      email: email,
      provider: "twitch",
      twitch_id: uid,
      twitch_avatar: image
    }
  end

  def oauth_token_attrs(%Ueberauth.Auth{
        uid: uid,
        provider: :twitch,
        credentials: %Ueberauth.Auth.Credentials{
          token: token,
          refresh_token: refresh_token,
          scopes: scopes
        }
      }) do
    %{
      user_id: uid,
      access_token: token,
      refresh_token: refresh_token,
      scopes: scopes
    }
  end
end
