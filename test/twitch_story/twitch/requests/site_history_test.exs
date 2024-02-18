defmodule TwitchStory.Twitch.Requests.SiteHistoryTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Twitch.Requests.SiteHistory

  @zip ~c"priv/static/request-1.zip"

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
