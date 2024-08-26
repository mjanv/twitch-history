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
      role: role?(String.downcase(name)),
      twitch_id: uid,
      twitch_avatar: image
    }
  end

  def role?("lanfeust313"), do: :admin
  def role?(_), do: :viewer

  def oauth_token_attrs(%Ueberauth.Auth{
        uid: uid,
        provider: :twitch,
        credentials: %Ueberauth.Auth.Credentials{
          token: token,
          refresh_token: refresh_token,
          scopes: scopes,
          expires_at: expires_at
        }
      }) do
    %{
      user_id: uid,
      access_token: token,
      refresh_token: refresh_token,
      scopes: scopes,
      expires_at: DateTime.from_unix!(expires_at)
    }
  end
end
