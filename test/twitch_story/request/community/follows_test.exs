defmodule TwitchStory.Request.Community.FollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Request.Community.Follows

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    follows = Follows.read(@zip)

    assert follows == nil
  end
end
