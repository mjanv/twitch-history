defmodule TwitchStory.Twitch.Requests.ZipfileTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Twitch.Requests.Zipfile

  @path ~c"priv/static/request-1.zip"

  test "list/1" do
    list = Zipfile.list(@path)

    assert list == [
             ~c"request/account/info/login_rename.csv",
             ~c"request/account/info/update_email.csv",
             ~c"request/account/security/auth_failure_two_factor.csv",
             ~c"request/account/security/auth_success_two_factor.csv",
             ~c"request/account/security/connections_connect.csv",
             ~c"request/account/security/login.csv",
             ~c"request/account/security/logout.csv",
             ~c"request/account/security/oauth_authorize.csv",
             ~c"request/account/security/oauth_deauthorize.csv",
             ~c"request/account/security/two_factor_disabled.csv",
             ~c"request/account/security/two_factor_enabled.csv",
             ~c"request/account/security/update_password.csv",
             ~c"request/commerce/bits/bits_acquired.csv",
             ~c"request/commerce/bits/bits_cheered.csv",
             ~c"request/commerce/subs/subscriptions.csv",
             ~c"request/community/follows/follow.csv",
             ~c"request/community/follows/follow_game.csv",
             ~c"request/community/follows/unfollow.csv",
             ~c"request/community/follows/unfollow_game.csv",
             ~c"request/site_history/chat_messages.csv",
             ~c"request/site_history/minute_broadcast.csv",
             ~c"request/site_history/minute_watched.csv",
             ~c"request/site_history/pageview.csv",
             ~c"request/site_history/search_query.csv",
             ~c"request/site_history/video_play.csv",
             ~c"request/users/channel/441903922.json",
             ~c"request/users/raid-settings/raids-raidsettings.json",
             ~c"request/users/user/441903922.json",
             ~c"request/metadata.json"
           ]
  end

  test "json/2" do
    file = ~c"request/users/channel/441903922.json"

    json = Zipfile.json(@path, file)

    assert json == %{
             "id" => "441903922",
             "broadcasterLanguage" => "fr",
             "broadcasterSoftware" => "unknown_rtmp",
             "game" => "Science & Technology",
             "gameId" => "509670",
             "lastBroadcastId" => "40325341829",
             "name" => "lanfeust313",
             "status" => "-",
             "title" => "-",
             "createdOn" => "2019-06-14T22:01:14.843812Z",
             "lastBroadcastTime" => "2023-12-29T12:20:23Z",
             "updatedOn" => "2024-01-04T17:58:20.556928Z"
           }
  end

  test "csv/2" do
    file = ~c"request/community/follows/follow.csv"

    csv = Zipfile.csv(@path, file)

    assert Map.get(csv, :__struct__) == Explorer.DataFrame
    assert Explorer.DataFrame.shape(csv) == {171, 33}
  end
end
