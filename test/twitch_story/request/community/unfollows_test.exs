defmodule TwitchStory.Request.Community.UnfollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Request.Community.Unfollows

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    unfollows = Unfollows.read(@zip)

    assert unfollows == nil
  end
end
