defmodule TwitchStory.Requests.Community.FollowsTest do
  @moduledoc false

  use ExUnit.Case

  alias Support.ExplorerCase
  alias TwitchStory.Requests.Community.Follows

  @zip ~c"priv/static/request-1.zip"

  test "n/2" do
    follows = Follows.n(@zip)

    assert follows == 169
  end

  test "all/2" do
    follows = Follows.all(Follows.read(@zip))

    assert ExplorerCase.equal_master?(follows, "follows")
  end
end
