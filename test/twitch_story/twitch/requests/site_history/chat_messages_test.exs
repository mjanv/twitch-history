defmodule TwitchStory.Twitch.Requests.SiteHistory.ChatMessagesTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :data

  alias Support.ExplorerCase
  alias TwitchStory.Twitch.Requests.SiteHistory.ChatMessages

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    chat_messages = ChatMessages.read(@zip)

    assert ExplorerCase.equal_master?(chat_messages, "chat_messages")
  end

  test "group_month_year/1" do
    chat_messages = ChatMessages.read(@zip)
    grouped = ChatMessages.group_month_year(chat_messages)

    assert Explorer.DataFrame.shape(grouped) == {429, 4}
  end
end
