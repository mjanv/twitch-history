defmodule TwitchStory.Twitch.Histories.SiteHistory.ChatMessages do
  @moduledoc false

  alias Explorer.Series
  alias TwitchStory.Twitch.Histories.SiteHistory
  alias TwitchStory.Twitch.Histories.Zipfile

  @dialyzer {:nowarn_function, group_channel: 1, group_month_year: 1}

  def read(file) do
    file
    |> Zipfile.csv(
      ~c"request/site_history/chat_messages.csv",
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
  end

  def group_channel(df) do
    df
    |> SiteHistory.preprocess()
    |> SiteHistory.group(
      [:channel],
      &[messages: Series.count(&1["body"]) |> Series.cast(:integer)],
      &[desc: &1["messages"]]
    )
  end

  def group_month_year(df) do
    df
    |> SiteHistory.preprocess()
    |> SiteHistory.group(
      [:channel, :month, :year],
      &[messages: Series.count(&1["body"]) |> Series.cast(:integer)],
      &[desc: &1["messages"]]
    )
  end
end
