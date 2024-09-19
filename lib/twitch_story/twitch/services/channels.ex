defmodule TwitchStory.Twitch.Services.Channels do
  @moduledoc false

  alias TwitchStory.Accounts
  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Auth
  alias TwitchStory.Twitch.Channels

  require Logger

  @doc """
  Sync a channel

  Get channel informations from the Twitch API to create or update a new Twitch channel. Channels are found through their broadcaster ID.
  """
  @spec sync_channel(String.t()) :: :ok
  def sync_channel(broadcaster_id) do
    with {:ok, attrs} <- Api.ChannelApi.channel(broadcaster_id) do
      case Channels.Channel.get!(broadcaster_id) do
        nil -> Channels.Channel.create(attrs)
        channel -> Channels.Channel.update(channel, attrs)
      end
    end

    :ok
  end

  @doc """
  Sync followed channels

  For a given user, retrieve all their followed channels and sync them
  """
  @spec sync_followed_channels(String.t()) :: :ok
  def sync_followed_channels(user_id) do
    with user <- Accounts.User.get(user_id),
         {:ok, token} <- Auth.OauthToken.get(user),
         {:ok, channels} <- Api.UserApi.followed_channels(token) do
      Accounts.FollowedChannel.follow_channels(user, channels)
    end
  end

  @doc """
  Sync clips

  For a given broadcaster, retrieve all clips generated in the last N days and sync them
  """
  @spec sync_last_clips(String.t(), Keyword.t()) :: :ok
  def sync_last_clips(broadcaster_id, shift_opts) do
    with {:ok, clips} <- Api.clips(broadcaster_id, shift_opts) do
      Logger.info("Found #{length(clips)} clips for #{broadcaster_id}")
      Enum.each(clips, &Channels.Clip.create/1)
    end
  end

  @doc """
  Find followed channels

  For a given user, find all their followed channels
  """
  @spec sync_followed_channels(String.t()) :: {:ok, [map()]}
  def find_followed_channels(user_id) do
    with user <- Accounts.User.get(user_id),
         {:ok, token} <- Auth.OauthToken.get(user) do
      Api.UserApi.followed_channels(token)
    end
  end
end
