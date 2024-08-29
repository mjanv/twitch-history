defmodule TwitchStory.Twitch.Services.Renewal do
  @moduledoc false

  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Auth

  def renew_access_token(user) do
    with {:ok, token} <- Auth.OauthToken.get(user),
         {:ok, body} <- Api.AuthApi.refresh_access_token(token.refresh_token),
         {:ok, token} <- Auth.OauthToken.update(body, user) do
      {:ok, token}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def sync_user(user) do
    with {:ok, token} <- Auth.OauthToken.get(user),
         {:ok, %{color: color}} <- Api.UserApi.color(token, user.twitch_id),
         {:ok, channels} <- Api.UserApi.followed_channels(token, user.twitch_id),
         {:ok, streams} <- Api.UserApi.live_streams(token, user.twitch_id) do
      {:ok, %{color: color, channels: channels, streams: streams}}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
