defmodule TwitchStory.Twitch.Requests.RequestTest do
  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Requests.{Metadata, Request}

  @zip ~c"priv/static/request-1.zip"

  test "create/1" do
    metadata = Metadata.read(@zip)
    request = Request.create(metadata)

    assert request == 1
  end
end
