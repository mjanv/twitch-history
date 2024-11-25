defmodule TwitchStory.ZipfileTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :data

  alias TwitchStory.Zipfile

  @path "priv/static/request-1.zip"

  test "list/1" do
    files = Zipfile.list(@path)

    assert files == [
             "request/account/info/login_rename.csv",
             "request/account/info/update_email.csv",
             "request/account/security/auth_failure_two_factor.csv",
             "request/account/security/auth_success_two_factor.csv",
             "request/account/security/connections_connect.csv",
             "request/account/security/login.csv",
             "request/account/security/logout.csv",
             "request/account/security/oauth_authorize.csv",
             "request/account/security/oauth_deauthorize.csv",
             "request/account/security/two_factor_disabled.csv",
             "request/account/security/two_factor_enabled.csv",
             "request/account/security/update_password.csv",
             "request/commerce/bits/bits_acquired.csv",
             "request/commerce/bits/bits_cheered.csv",
             "request/commerce/subs/subscriptions.csv",
             "request/community/follows/follow.csv",
             "request/community/follows/follow_game.csv",
             "request/community/follows/unfollow.csv",
             "request/community/follows/unfollow_game.csv",
             "request/site_history/chat_messages.csv",
             "request/site_history/minute_broadcast.csv",
             "request/site_history/minute_watched.csv",
             "request/site_history/pageview.csv",
             "request/site_history/search_query.csv",
             "request/site_history/video_play.csv",
             "request/users/channel/441903922.json",
             "request/users/raid-settings/raids-raidsettings.json",
             "request/users/user/441903922.json",
             "request/metadata.json"
           ]
  end

  test "json/2" do
    file = "request/users/channel/441903922.json"

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
    file = "request/community/follows/follow.csv"

    csv = Zipfile.csv(@path, file)

    assert Map.get(csv, :__struct__) == Explorer.DataFrame
    assert Explorer.DataFrame.shape(csv) == {171, 33}
  end
end
