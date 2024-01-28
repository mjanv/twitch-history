defmodule TwitchStory.Request.Community.Unfollows do
  @moduledoc false

  alias TwitchStory.Request.Zipfile

  require Explorer.DataFrame, as: DataFrame

  def read(file) do
    file
    |> Zipfile.csv(~c"request/community/follows/unfollow.csv")
    |> DataFrame.select(["time", "channel"])
  end
end
