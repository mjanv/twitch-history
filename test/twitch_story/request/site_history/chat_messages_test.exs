defmodule TwitchStory.Request.SiteHistory.ChatMessagesTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Request.SiteHistory.ChatMessages

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    chat_messages =
      ChatMessages.read(@zip)
      |> Explorer.DataFrame.head()
      |> Explorer.DataFrame.print()

    assert chat_messages == %{}
  end
end
