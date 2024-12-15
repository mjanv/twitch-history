defmodule TwitchStory.Twitch.Histories.SiteHistoryTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :zip

  alias TwitchStory.Twitch.Histories.SiteHistory

  @zip "priv/static/request-1.zip"

  test "preprocess/1" do
    messages = SiteHistory.ChatMessages.read(@zip)

    messages = SiteHistory.preprocess(messages)

    assert Explorer.DataFrame.names(messages) == [
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

  test "contains/2" do
    messages =
      @zip
      |> SiteHistory.ChatMessages.read()
      |> SiteHistory.contains(body: "bonjour")

    assert Explorer.DataFrame.shape(messages) == {16, 7}
  end

  test "equals/2" do
    messages =
      @zip
      |> SiteHistory.ChatMessages.read()
      |> SiteHistory.equals(channel: "sirgibsy")

    assert Explorer.DataFrame.shape(messages) == {109, 7}
  end
end
