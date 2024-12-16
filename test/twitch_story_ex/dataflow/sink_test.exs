defmodule TwitchStory.Dataflow.SinkTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :zip

  alias Explorer.DataFrame
  alias TwitchStory.Dataflow.Sink
  alias TwitchStory.Zipfile

  @zip "priv/static/request-1.zip"

  test "preprocess/1" do
    df =
      Zipfile.csv(
        @zip,
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

    messages = Sink.preprocess(df)

    assert DataFrame.names(messages) == [
             "time",
             "body_full",
             "body",
             "channel",
             "channel_points_modification",
             "is_reply",
             "is_mention",
             "year",
             "month",
             "day",
             "weekday",
             "hour"
           ]
  end
end
