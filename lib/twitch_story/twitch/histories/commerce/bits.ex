defmodule TwitchStory.Twitch.Histories.Commerce.Bits do
  @moduledoc false

  alias TwitchStory.Twitch.Histories.Zipfile

  # ~c"request/commerce/bits/bits_acquired.csv"
  # ~c"request/commerce/bits/bits_cheered.csv"

  def read(file) do
    file
    |> Zipfile.csv(~c"request/commerce/bits/bits_acquired.csv")
  end
end
