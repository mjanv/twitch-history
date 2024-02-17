defmodule TwitchStory.Notifications.LogTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias TwitchStory.Notifications.Log

  test "A message can be logged" do
    assert capture_log(fn -> Log.deliver_message("Hello, world!") end) =~ "Hello, world!"
  end
end
