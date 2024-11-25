defmodule TwitchStory.Twitch.Histories.Community.Follows do
  @moduledoc false

  require Explorer.DataFrame, as: DataFrame

  alias Explorer.Series

  alias TwitchStory.Twitch.Histories.SiteHistory
  alias TwitchStory.Zipfile

  def read(file) do
    Zipfile.csv(
      file,
      "request/community/follows/follow.csv",
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

  def group_month_year(df) do
    df
    |> SiteHistory.preprocess()
    |> SiteHistory.group(
      [:month, :year],
      &[
        follows: Series.n_distinct(&1["channel"])
      ],
      &[desc: &1["follows"]]
    )
  end
end
