defmodule TwitchStory.Twitch.Histories.SiteHistory do
  @moduledoc false

  require Explorer.DataFrame, as: DF

  alias Explorer.Series

  def nominal_date_column(df) do
    {df["year"], df["month"]}
    |> then(fn {y, m} -> Enum.zip(as_string(y), as_string(m)) end)
    |> Enum.map(fn {y, m} -> "#{y}-#{String.pad_leading(m, 2, "0")}" end)
    |> Series.from_list()
    |> then(fn s -> DF.put(df, "date", s) end)
  end

  defp as_string(s), do: s |> Series.cast(:string) |> Series.to_list()

  def preprocess(df, column \\ "time") do
    df
    |> DF.mutate_with(
      &[
        year: Series.year(&1[column]),
        month: Series.month(&1[column]),
        day: Series.day_of_year(&1[column]),
        weekday: Series.day_of_week(&1[column]),
        hour: Series.hour(&1[column])
      ]
    )
  end

  # Filters
  def filter(df, column, value), do: DF.filter(df, col(^column) == ^value)

  def window(df, start, stop, column),
    do: DF.filter(df, ^start <= col(^column) and col(^column) <= ^stop)

  def equals(df, [{n, q} | t]), do: df |> filter(n, q) |> equals(t)
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
