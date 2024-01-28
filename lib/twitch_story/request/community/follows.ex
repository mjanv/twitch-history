defmodule TwitchStory.Request.Community.Follows do
  @moduledoc false

  alias TwitchStory.Request.Zipfile

  require Explorer.DataFrame, as: DataFrame

  def read(file) do
    Zipfile.csv(
      file,
      ~c"request/community/follows/follow.csv",
      columns: ["time", "channel"],
      dtypes: [{"time", {:datetime, :microsecond}}]
    )
  end

  def all(file) do
    file
    |> read()
    |> DataFrame.filter(not is_nil(channel))
    |> DataFrame.sort_by(asc: time)
    |> DataFrame.group_by([:channel])
    |> DataFrame.summarise_with(&[time: Explorer.Series.first(&1["time"])])
  end

  def count(file) do
    file
    |> read()
    |> DataFrame.filter(not is_nil(channel))
    |> DataFrame.shape()
    |> elem(0)
  end
end
