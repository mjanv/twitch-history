defmodule TwitchStory.Request.Community.FollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Request.Community.Follows

  @zip ~c"priv/static/request-1.zip"

  test "count/2" do
    follows = Follows.count(@zip)

    assert follows == 169
  end

  test "all/2" do
    follows = Follows.all(@zip)

    assert follows ==
             Explorer.DataFrame.from_parquet!(
               "test/twitch_story/request/community/follows.parquet"
             )
  end
end
