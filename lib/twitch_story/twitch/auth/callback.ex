defmodule TwitchStory.Twitch.Auth.Callback do
  @moduledoc false

  alias Ueberauth.Auth

  @type role() :: :admin | :streamer | :viewer

  @doc "Returns the attributes of a user from Ueberauth callback data"
  @spec user_attrs(Ueberauth.Auth.t()) :: %{
          required(:name) => String.t(),
          required(:email) => String.t(),
          required(:provider) => String.t(),
          required(:role) => role(),
          optional(:twitch_id) => String.t(),
          optional(:twitch_avatar) => String.t()
        }
  def user_attrs(%Auth{
        uid: uid,
        provider: :twitch,
        info: %Auth.Info{name: name, email: email, image: image}
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

  @spec role?(String.t()) :: role()
  defp role?("lanfeust313"), do: :admin
  defp role?("flonflon"), do: :streamer
  defp role?(_), do: :viewer

  def oauth_token_attrs(%Auth{
        uid: uid,
        provider: :twitch,
        credentials: %Auth.Credentials{
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
