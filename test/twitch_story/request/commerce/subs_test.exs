defmodule TwitchStory.Request.Commerce.SubsTest do
  @moduledoc false

  use ExUnit.Case

  alias Support.ExplorerCase
  alias TwitchStory.Request.Commerce.Subs

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    subs = Subs.read(@zip)

    assert ExplorerCase.equal_master?(subs, "subs")
  end
end
