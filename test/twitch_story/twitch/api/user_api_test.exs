defmodule TwitchStory.Twitch.Api.UserApiTest do
  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Api.UserApi

  @moduletag :api

  setup do
    token =
      %{
        access_token: System.fetch_env!("TWITCH_USER_ACCESS_TOKEN"),
        refresh_token: System.fetch_env!("TWITCH_USER_REFRESH_TOKEN"),
        user_id: System.fetch_env!("TWITCH_USER_ID")
      }

    {:ok, %{token: token}}
  end

  test "user/1", %{token: token} do
    {:ok, user} = UserApi.user(token)

    assert user == %{
             created_at: "2019-06-14T22:01:14Z",
             display_name: "Lanfeust313",
             email: "lanfeust_313@hotmail.com",
             id: token.user_id,
             login: "lanfeust313",
             profile_image_url:
               "https://static-cdn.jtvnw.net/jtv_user_pictures/5bb33c91-8797-4f46-bc9f-3e72731b8c38-profile_image-300x300.png"
           }
  end

  test "color/1", %{token: token} do
    {:ok, color} = UserApi.color(token, %{id: nil})

    assert color == %{color: "#E4AE26"}
  end

  test "followed_channels/1", %{token: token} do
    {:ok, channels} = UserApi.followed_channels(token)

    assert length(channels) > 0

    for channel <- channels do
      assert Map.keys(channel) == [:user_id, :user_login, :user_name]
    end
  end
end
