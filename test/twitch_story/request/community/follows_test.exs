defmodule TwitchStory.Request.Community.FollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias Explorer.DataFrame
  alias Support.ExplorerCase
  alias TwitchStory.Request.Community.Follows

  @zip ~c"priv/static/request-1.zip"

  test "count/2" do
    follows = Follows.count(@zip)

    assert follows == 169
  end

  test "all/2" do
    follows = Follows.all(@zip)
    truth = DataFrame.from_parquet!("test/support/data/follows.parquet")

    assert ExplorerCase.dataframes_equal?(follows, truth)
  end
end
