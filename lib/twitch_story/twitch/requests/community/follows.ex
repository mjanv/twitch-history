defmodule TwitchStory.Twitch.Requests.Community.Follows do
  @moduledoc false

  alias TwitchStory.Twitch.Requests.Zipfile

  require Explorer.DataFrame, as: DataFrame

  def read(file) do
    Zipfile.csv(
      file,
      ~c"request/community/follows/follow.csv",
      columns: ["time", "channel"],
      dtypes: [{"time", {:naive_datetime, :microsecond}}]
    )
  end

  def all(df) do
    df
    |> DataFrame.filter(not is_nil(channel))
    |> DataFrame.sort_by(asc: time)
    |> DataFrame.group_by([:channel])
    |> DataFrame.summarise_with(&[follow: Explorer.Series.first(&1["time"])])
  end

  def n(file) do
    file
    |> read()
    |> DataFrame.filter(not is_nil(channel))
    |> DataFrame.n_rows()
  end
end
