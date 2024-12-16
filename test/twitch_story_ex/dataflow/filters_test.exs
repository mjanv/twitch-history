defmodule TwitchStory.Dataflow.FiltersTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :zip

  alias Explorer.DataFrame
  alias TwitchStory.Dataflow.Filters
  alias TwitchStory.Twitch.Histories.SiteHistory.ChatMessages

  @zip "priv/static/request-1.zip"

  setup do
    messages = ChatMessages.read(@zip)
    {:ok, messages: messages}
  end

  test "contains/2", %{messages: messages} do
    messages = Filters.contains(messages, body: "bonjour")

    assert DataFrame.shape(messages) == {16, 12}
  end

  test "equals/2", %{messages: messages} do
    messages = Filters.equals(messages, channel: "sirgibsy")

    assert DataFrame.shape(messages) == {109, 12}
  end
end
