defmodule TwitchStory.Twitch.Requests.Community.Unfollows do
  @moduledoc false

  alias TwitchStory.Twitch.Requests.Zipfile

  require Explorer.DataFrame, as: DataFrame

  def read(file) do
    Zipfile.csv(
      file,
      ~c"request/community/follows/unfollow.csv",
      columns: ["time", "channel"],
      dtypes: [{"time", {:datetime, :microsecond}}]
    )
  end

  def all(file) do
    file
    |> read()
    |> DataFrame.filter(not is_nil(channel))
  end

  def count(file) do
    file
    |> read()
    |> DataFrame.filter(not is_nil(channel))
    |> DataFrame.shape()
    |> elem(0)
  end
end
