defmodule TwitchStory.Twitch.Histories.SiteHistory.ChatMessages do
  @moduledoc false

  @behaviour TwitchStory.Dataflow.Sink

  alias Explorer.Series
  alias TwitchStory.Dataflow.Filters
  alias TwitchStory.Dataflow.Sink
  alias TwitchStory.Zipfile

  @impl true
  def read(file) do
    file
    |> Zipfile.csv(
      "request/site_history/chat_messages.csv",
      columns: [
        "time",
        "channel",
        "body",
        "body_full",
        "is_reply",
        "is_mention",
        "channel_points_modification"
      ],
      dtypes: [{"time", {:naive_datetime, :microsecond}}]
    )
    |> Sink.preprocess()
  end

  def group_channel(df) do
    df
    |> Filters.group(
      [:channel],
      &[messages: Series.count(&1["body"]) |> Series.cast(:integer)],
      &[desc: &1["messages"]]
    )
  end

  def group_month_year(df) do
    df
    |> Filters.group(
      [:channel, :month, :year],
      &[messages: Series.count(&1["body"]) |> Series.cast(:integer)],
      &[desc: &1["messages"]]
    )
  end
end
