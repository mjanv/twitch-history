defmodule TwitchStory.Twitch.Auth.CallbackTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias TwitchStory.Twitch.Auth.Callback

  @ueberauth_auth %Ueberauth.Auth{
    uid: "441903922",
    provider: :twitch,
    strategy: Ueberauth.Strategy.Twitch,
    info: %Ueberauth.Auth.Info{
      name: "lanfeust313",
      first_name: nil,
      last_name: nil,
      nickname: "lanfeust313",
      email: "lanfeust_313@hotmail.com",
      location: nil,
      description: "",
      image:
        "https://static-cdn.jtvnw.net/user-default-pictures-uv/75305d54-c7cc-40d1-bb9c-91fbe85943c7-profile_image-300x300.png",
      phone: nil,
      birthday: nil,
      urls: %{}
    },
    credentials: %Ueberauth.Auth.Credentials{
      token: "hzt0dmrje10l31yaalswp73laauqd5",
      refresh_token: "qcvjs5l6efp22lzvhowzlwmlvbi76lnoxn2pze8yv7i18om724",
      token_type: nil,
      secret: nil,
      expires: true,
      expires_at: 1_708_147_736,
      scopes: ["user:read:email"],
      other: %{}
    },
    extra: %Ueberauth.Auth.Extra{
      raw_info: %{
        user: %{
          "data" => [
            %{
              "broadcaster_type" => "",
              "created_at" => "2019-06-14T22:01:14Z",
              "description" => "",
              "display_name" => "lanfeust313",
              "email" => "lanfeust_313@hotmail.com",
              "id" => "441903922",
              "login" => "lanfeust313",
              "offline_image_url" => "",
              "profile_image_url" =>
                "https://static-cdn.jtvnw.net/user-default-pictures-uv/75305d54-c7cc-40d1-bb9c-91fbe85943c7-profile_image-300x300.png",
              "type" => "",
              "view_count" => 0
            }
          ]
        },
        token: %OAuth2.AccessToken{
          access_token: "hzt0dmrje10l31yaalswp73laauqd5",
          refresh_token: "qcvjs5l6efp22lzvhowzlwmlvbi76lnoxn2pze8yv7i18om724",
          expires_at: 1_708_147_736,
          token_type: "Bearer",
          other_params: %{"scope" => ["user:read:email"]}
        }
      }
    }
  }

  test "Callback success can be converted to user parameters" do
    attrs = Callback.user_attrs(@ueberauth_auth)

    assert attrs == %{
             name: "lanfeust313",
             email: "lanfeust_313@hotmail.com",
             provider: "twitch",
             role: :admin,
             twitch_id: "441903922",
             twitch_avatar:
               "https://static-cdn.jtvnw.net/user-default-pictures-uv/75305d54-c7cc-40d1-bb9c-91fbe85943c7-profile_image-300x300.png"
           }
  end

  test "Callback success can be converted to user Twitch tokens parameters" do
    attrs = Callback.oauth_token_attrs(@ueberauth_auth)

    assert attrs == %{
             user_id: "441903922",
             access_token: "hzt0dmrje10l31yaalswp73laauqd5",
             refresh_token: "qcvjs5l6efp22lzvhowzlwmlvbi76lnoxn2pze8yv7i18om724",
             scopes: ["user:read:email"],
             expires_at: ~U[2024-02-17 05:28:56Z]
           }
  end
end
