defmodule TwitchStory.Request.Community.UnfollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Request.Community.Unfollows

  @zip ~c"priv/static/request-1.zip"

  test "count/2" do
    unfollows = Unfollows.count(@zip)

    assert unfollows == 1
  end

  test "all/2" do
    unfollows = Unfollows.all(@zip)

    assert unfollows ==
             Explorer.DataFrame.from_parquet!(
               "test/twitch_story/request/community/unfollows.parquet"
             )
  end
end
