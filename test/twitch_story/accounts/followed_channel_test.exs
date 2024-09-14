defmodule TwitchStory.Accounts.FollowedChannelTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures
  import TwitchStory.TwitchFixtures

  alias TwitchStory.Accounts.FollowedChannel

  describe "follow_channels/1" do
    test "attach channels to an existing user" do
      user = user_fixture()
      channel = channel_fixture()

      attrs = %{
        broadcaster_id: channel.broadcaster_id,
        broadcaster_login: channel.broadcaster_login,
        broadcaster_name: channel.broadcaster_name,
        followed_at: ~U[2024-10-12T23:45:12Z]
      }

      :ok = FollowedChannel.follow_channels(user, [attrs])
      [%FollowedChannel{} = followed_channel] = FollowedChannel.all(user_id: user.id)

      # assert followed_channel.user_id = user.id
      assert followed_channel.channel_id == channel.id
      assert followed_channel.followed_at == ~U[2024-10-12T23:45:12Z]

      assert followed_channel.channel.broadcaster_id == channel.broadcaster_id
      assert followed_channel.channel.broadcaster_name == channel.broadcaster_name
      assert followed_channel.channel.broadcaster_login == channel.broadcaster_login
    end

    test "does not attach twice channels to an existing user" do
      user = user_fixture()
      channel = channel_fixture()

      attrs = %{
        broadcaster_id: channel.broadcaster_id,
        broadcaster_login: channel.broadcaster_login,
        broadcaster_name: channel.broadcaster_name,
        followed_at: ~U[2024-10-12T23:45:12Z]
      }

      :ok = FollowedChannel.follow_channels(user, [attrs])

      attrs = %{
        broadcaster_id: channel.broadcaster_id,
        broadcaster_login: channel.broadcaster_login,
        broadcaster_name: channel.broadcaster_name,
        followed_at: ~U[2025-12-23T23:45:12Z]
      }

      :ok = FollowedChannel.follow_channels(user, [attrs])

      [%FollowedChannel{} = followed_channel] = FollowedChannel.all(user_id: user.id)

      assert followed_channel.channel_id == channel.id
      assert followed_channel.followed_at == ~U[2025-12-23T23:45:12Z]
    end
  end
end
