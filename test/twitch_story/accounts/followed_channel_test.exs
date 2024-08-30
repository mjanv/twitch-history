defmodule TwitchStory.Accounts.FollowedChannelTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Accounts.FollowedChannel
  alias TwitchStory.Twitch.Channels

  describe "follow_channels/1" do
    test "attach channels to an existing user" do
      user = user_fixture()

      id = UUID.uuid4()

      {:ok, channel} =
        Channels.Channel.create(%{
          broadcaster_id: id,
          broadcaster_login: "login",
          broadcaster_name: "name"
        })

      attrs = %{
        broadcaster_id: channel.broadcaster_id,
        broadcaster_login: channel.broadcaster_login,
        broadcaster_name: channel.broadcaster_name,
        followed_at: ~N[2024-10-12T23:45:12Z]
      }

      {:ok, [%FollowedChannel{} = followed_channel]} =
        FollowedChannel.follow_channels(user, [attrs])

      # assert followed_channel.user_id = user.id
      assert followed_channel.channel_id == channel.id
      assert followed_channel.followed_at == ~U[2024-10-12T23:45:12Z]

      assert followed_channel.channel.broadcaster_id == channel.broadcaster_id
      assert followed_channel.channel.broadcaster_name == "name"
      assert followed_channel.channel.broadcaster_login == "login"
    end
  end
end
