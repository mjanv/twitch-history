defmodule TwitchStory.Twitch.Histories.SiteHistory.MinuteWatched do
  @moduledoc false

  require Explorer.DataFrame, as: DataFrame

  alias Explorer.Series
  alias TwitchStory.Dataflow.Filters
  alias TwitchStory.Dataflow.Sink
  alias TwitchStory.Zipfile

  @dialyzer {:nowarn_function, remove_unwatched_channels: 2}

  def read(file) do
    file
    |> Zipfile.csv(
      "request/site_history/minute_watched.csv",
      columns: ["time", "channel", "minutes_logged", "game"],
      dtypes: [{"time", {:naive_datetime, :microsecond}}]
    )
    |> Sink.preprocess()
  end

  def remove_unwatched_channels(df, threshold) do
    df
    |> DataFrame.group_by([:channel])
    |> DataFrame.filter(count(minutes_logged) > ^threshold)
    |> DataFrame.ungroup()
  end

  def group_channel(df) do
    df
    |> Filters.group(
      [:channel],
      &[
        hours: Series.count(&1["minutes_logged"]) |> Series.divide(60) |> Series.cast(:integer)
      ],
      &[desc: &1["hours"]]
    )
  end

  def group_month_year(df) do
    df
    |> Filters.group(
      [:channel, :month, :year],
      &[
        hours: Series.count(&1["minutes_logged"]) |> Series.divide(60) |> Series.cast(:integer),
        channels: Series.n_distinct(&1["channel"])
      ],
      &[desc: &1["hours"]]
    )
  end
end
