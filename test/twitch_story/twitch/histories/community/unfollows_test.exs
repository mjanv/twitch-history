defmodule TwitchStory.Twitch.Histories.Community.UnfollowsTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :zip

  alias Support.ExplorerCase
  alias TwitchStory.Twitch.Histories.Community.Unfollows

  @zip "priv/static/request-1.zip"

  test "count/2" do
    unfollows = Unfollows.count(@zip)

    assert unfollows == 1
  end

  test "all/2" do
    unfollows = Unfollows.all(@zip)

    assert ExplorerCase.equal_master?(unfollows, "unfollows")
  end
end
