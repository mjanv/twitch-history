defmodule TwitchStory.Twitch.Services.Channels do
  @moduledoc false

  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Auth
  alias TwitchStory.Twitch.Channels.Channel

  def sync_channel(broadcaster_id) do
    with {:ok, attrs} <- Api.ChannelApi.channel(broadcaster_id) do
      case Channel.get!(broadcaster_id) do
        nil -> Channel.create(attrs)
        channel -> Channel.update(channel, attrs)
      end
    end
  end

  def sync_channels(user_id) do
    with user <- User.get(user_id),
         {:ok, token} <- Auth.OauthToken.get(user),
         {:ok, channels} <- Api.UserApi.followed_channels(token, user.twitch_id) do
      {:ok, channels}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
