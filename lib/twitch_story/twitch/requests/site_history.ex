defmodule TwitchStory.Twitch.Requests.SiteHistory do
  @moduledoc false

  require Explorer.DataFrame, as: DF

  alias Explorer.Series

  def as_string(s), do: s |> Series.cast(:string) |> Series.to_list()

  def nominal_date_column(df) do
    {df["year"], df["month"]}
    |> then(fn {y, m} -> Enum.zip(as_string(y), as_string(m)) end)
    |> Enum.map(fn {y, m} -> "#{y}-#{String.pad_leading(m, 2, "0")}" end)
    |> Series.from_list()
    |> then(fn s -> DF.put(df, "date", s) end)
  end

  def preprocess(df) do
    df
    |> DF.mutate(
      year: year(time),
      month: month(time),
      day: day_of_year(time),
      weekday: day_of_week(time),
      hour: hour(time)
    )
  end

  # Statistics
  def n_rows(df, divider \\ 1) do
    df
    |> DF.n_rows()
    |> Kernel./(divider)
    |> Kernel.round()
  end

  # Filters
  def channel(df, channel), do: DF.filter(df, channel == ^channel)
  def years(df, start, stop), do: DF.filter(df, ^start <= year and year <= ^stop)

  def equals(df, [{n, q} | t]), do: df |> DF.filter(col(^n) == ^q) |> equals(t)
  def equals(df, []), do: df

  def contains(df, [{n, q} | t]),
    do: df |> DF.filter_with(&Series.contains(&1[n], q)) |> contains(t)

  def contains(df, []), do: df

  # Groups
  # def group_channel(df, summary), do: group(df, summary, [:channel])
  # def group_month(df, summary), do: group(df, summary, [:month, :year]) |> nominal_date_column()
  # def group_channel_month(df, summary), do: group(df, summary, [:channel, :month, :year]) |> nominal_date_column()
  # def group_week(df, summary), do: group(df, summary, [:weekday])

  def group(df, columns, summary, sorts) do
    df
    |> DF.group_by(columns)
    |> DF.summarise_with(summary)
    |> DF.sort_with(sorts)
  end
end
