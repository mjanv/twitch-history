defmodule TwitchStory.Twitch.Histories.Commerce.SubsTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :zip

  alias Support.ExplorerCase
  alias TwitchStory.Twitch.Histories.Commerce.Subs

  @zip "priv/static/request-1.zip"

  test "read/2" do
    subs = Subs.read(@zip)

    assert ExplorerCase.equal_master?(subs, "subs")
  end
end
