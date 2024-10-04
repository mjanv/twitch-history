defmodule TwitchStory.Games.EurovisionTest do
  use TwitchStory.DataCase

  alias TwitchStory.Games.Eurovision

  test "Available points for a ceremony can be retrieved" do
    assert Eurovision.points(:asc) == [1, 2, 3, 4, 5, 6, 7, 8, 10, 12]
    assert Eurovision.points(:desc) == [12, 10, 8, 7, 6, 5, 4, 3, 2, 1]
  end
end
