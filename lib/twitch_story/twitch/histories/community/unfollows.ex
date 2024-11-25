defmodule TwitchStory.Twitch.Histories.Community.Unfollows do
  @moduledoc false

  alias TwitchStory.Zipfile

  require Explorer.DataFrame, as: DataFrame

  def read(file) do
    Zipfile.csv(
      file,
      "request/community/follows/unfollow.csv",
      columns: ["time", "channel"],
      dtypes: [{"time", {:naive_datetime, :microsecond}}]
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
