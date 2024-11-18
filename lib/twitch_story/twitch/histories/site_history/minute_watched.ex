defmodule TwitchStory.Twitch.Histories.SiteHistory.MinuteWatched do
  @moduledoc false

  alias Explorer.Series
  alias TwitchStory.Twitch.Histories.SiteHistory
  alias TwitchStory.Twitch.Histories.Zipfile

  require Explorer.DataFrame, as: DataFrame

  @dialyzer {:nowarn_function,
             group_channel: 1,
             group_month_year: 1,
             remove_unwatched_channels: 1,
             remove_unwatched_channels: 2}

  def read(file) do
    file
    |> Zipfile.csv(
      ~c"request/site_history/minute_watched.csv",
      columns: ["time", "channel", "minutes_logged", "game"],
      dtypes: [{"time", {:naive_datetime, :microsecond}}]
    )
  end

  def remove_unwatched_channels(df, threshold \\ 60) do
    df
    |> DataFrame.group_by([:channel])
    |> DataFrame.filter(count(minutes_logged) > ^threshold)
    |> DataFrame.ungroup()
  end

  def group_channel(df) do
    df
    |> SiteHistory.preprocess()
    |> SiteHistory.group(
      [:channel],
      &[
        hours: Series.count(&1["minutes_logged"]) |> Series.divide(60) |> Series.cast(:integer)
      ],
      &[desc: &1["hours"]]
    )
  end

  def group_month_year(df) do
    df
    |> SiteHistory.preprocess()
    |> SiteHistory.group(
      [:channel, :month, :year],
      &[
        hours: Series.count(&1["minutes_logged"]) |> Series.divide(60) |> Series.cast(:integer),
        channels: Series.n_distinct(&1["channel"])
      ],
      &[desc: &1["hours"]]
    )
  end
end
