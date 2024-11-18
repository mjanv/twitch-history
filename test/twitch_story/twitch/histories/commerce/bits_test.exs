defmodule TwitchStory.Twitch.Histories.Commerce.BitsTest do
  @moduledoc false

  use ExUnit.Case

  @moduletag :data

  alias TwitchStory.Twitch.Histories.Commerce.Bits

  @zip ~c"priv/static/request-1.zip"

  test "read/2" do
    bits = Bits.read(@zip)

    assert Explorer.DataFrame.shape(bits) == {0, 22}
  end
end
