defmodule TwitchStory.Twitch.Histories.SiteHistory.MinuteWatchedTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :data

  alias Support.ExplorerCase
  alias TwitchStory.Twitch.Histories.SiteHistory.MinuteWatched

  @zip "priv/static/request-1.zip"

  test "read/2" do
    minute_watched = MinuteWatched.read(@zip)

    assert ExplorerCase.equal_master?(minute_watched, "minute_watched")
  end
end
