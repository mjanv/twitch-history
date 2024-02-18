defmodule TwitchStory.Twitch.Requests.Community.UnfollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias Support.ExplorerCase
  alias TwitchStory.Twitch.Requests.Community.Unfollows

  @zip ~c"priv/static/request-1.zip"

  test "count/2" do
    unfollows = Unfollows.count(@zip)

    assert unfollows == 1
  end

  test "all/2" do
    unfollows = Unfollows.all(@zip)

    assert ExplorerCase.equal_master?(unfollows, "unfollows")
  end
end
