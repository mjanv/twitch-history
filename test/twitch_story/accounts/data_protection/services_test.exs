defmodule TwitchStory.Accounts.DataProtection.ServicesTest do
  use TwitchStory.DataCase, async: true

  alias TwitchStory.Accounts.DataProtection.Services
  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.FollowedChannel

  setup do
    user = user_fixture()
    channel = channel_fixture()

    channel = %{
      broadcaster_id: channel.broadcaster_id,
      broadcaster_login: channel.broadcaster_login,
      broadcaster_name: channel.broadcaster_name,
      followed_at: ~U[2024-10-12T23:45:12Z]
    }

    FollowedChannel.follow_channels(user, [channel])

    {:ok, user: user, channel: channel}
  end

  test "extract_user_data/1", %{user: user, channel: channel} do
    user_data = Services.extract_user_data(user)

    event?(%DataExportRequested{id: user.id})
    event?(%DataExportGenerated{id: user.id})

    assert Map.keys(user_data) == ["events", "followed_channels", "user"]

    assert user_data["user"] == %{
             "name" => user.name,
             "email" => user.email,
             "role" => "viewer",
             "twitch_id" => user.twitch_id,
             "twitch_avatar" => user.twitch_avatar
           }

    [
      %{"event" => "UserCreated", "id" => id1, "at" => at1},
      %{"event" => "DataExportRequested", "id" => id2, "at" => at2}
    ] = user_data["events"]

    assert id1 == user.id
    assert {:ok, _, _} = DateTime.from_iso8601(at1)

    assert id2 == user.id
    assert {:ok, _, _} = DateTime.from_iso8601(at2)

    assert user_data["followed_channels"] == [
             %{
               "channel" => %{
                 "broadcaster_id" => channel.broadcaster_id,
                 "broadcaster_login" => channel.broadcaster_login,
                 "broadcaster_name" => channel.broadcaster_name
               },
               "followed_at" => DateTime.to_iso8601(channel.followed_at)
             }
           ]
  end

  test "delete_user_data/1", %{user: user} do
    :ok = Services.delete_user_data(user)

    stream?([%UserCreated{id: user.id}, %UserDeleted{id: user.id}])

    assert User.get(user.id) == nil
    assert FollowedChannel.all(user_id: user.id) == []
  end
end
