defmodule TwitchStory.Request.Community.UnfollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias Explorer.DataFrame
  alias Support.ExplorerCase
  alias TwitchStory.Request.Community.Unfollows

  @zip ~c"priv/static/request-1.zip"

  test "count/2" do
    unfollows = Unfollows.count(@zip)

    assert unfollows == 1
  end

  test "all/2" do
    unfollows = Unfollows.all(@zip)
    truth = DataFrame.from_parquet!("test/support/data/unfollows.parquet")

    assert ExplorerCase.dataframes_equal?(unfollows, truth)
  end
end
