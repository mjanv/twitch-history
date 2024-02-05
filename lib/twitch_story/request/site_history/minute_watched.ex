defmodule TwitchStory.Request.SiteHistory.MinuteWatched do
  @moduledoc false

  alias TwitchStory.Request.Zipfile

  require Explorer.DataFrame, as: DataFrame

  alias Explorer.Series

  def read(file) do
    file
    |> Zipfile.csv(
      ~c"request/site_history/minute_watched.csv",
      columns: ["time", "channel", "minutes_logged", "game"],
      dtypes: [{"time", {:datetime, :microsecond}}]
    )
  end

  def n(file) do
    file
    |> read()
    |> DataFrame.n_rows()
    |> Kernel./(60)
    |> Kernel.round()
  end

  def as_string(s), do: s |> Series.cast(:string) |> Series.to_list()

  def nominal_date_column(df) do
    {df["year"], df["month"]}
    |> then(fn {y, m} -> Enum.zip(as_string(y), as_string(m)) end)
    |> Enum.map(fn {y, m} -> "#{y}-#{String.pad_leading(m, 2, "0")}" end)
    |> Series.from_list()
    |> then(fn s -> DataFrame.put(df, "date", s) end)
  end

  def remove_unwatched_channels(df, threshold \\ 60) do
    df
    |> DataFrame.group_by([:channel])
    |> DataFrame.filter(count(minutes_logged) > ^threshold)
    |> DataFrame.ungroup()
  end

  def preprocess(df, threshold: threshold) do
    df
    |> DataFrame.mutate(year: year(time), month: month(time), weekday: day_of_week(time))
    |> DataFrame.mutate(hour: hour(time))
    |> remove_unwatched_channels(threshold)
  end

  # Filters
  def channel(df, channel), do: DataFrame.filter(df, channel == ^channel)
  def years(df, start, stop), do: DataFrame.filter(df, ^start <= year and year <= ^stop)

  # Groups
  def group_channel(df), do: group(df, [:channel])
  def group_month(df), do: group(df, [:month, :year]) |> nominal_date_column()
  def group_channel_month(df), do: group(df, [:channel, :month, :year]) |> nominal_date_column()
  def group_week(df), do: group(df, [:weekday])

  defp group(df, columns) do
    df
    |> DataFrame.group_by(columns)
    |> DataFrame.summarise_with(
      &[
        total: Series.count(&1["minutes_logged"]) |> Series.divide(60) |> Series.cast(:integer),
        channels: Series.n_distinct(&1["channel"])
      ]
    )
    |> DataFrame.sort_by(desc: total)
  end
end
