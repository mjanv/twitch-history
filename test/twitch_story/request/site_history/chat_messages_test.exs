defmodule TwitchStory.Request.SiteHistory.ChatMessagesTest do
  @moduledoc false

  use ExUnit.Case

  alias Support.ExplorerCase
  alias TwitchStory.Request.SiteHistory.ChatMessages

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    chat_messages = ChatMessages.read(@zip)

    assert ExplorerCase.equal_master?(chat_messages, "chat_messages")
  end
end
