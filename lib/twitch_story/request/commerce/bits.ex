defmodule TwitchStory.Request.Commerce.Bits do
  @moduledoc false

  alias TwitchStory.Request.Zipfile

  # ~c"request/commerce/bits/bits_acquired.csv"
  # ~c"request/commerce/bits/bits_cheered.csv"

  def read(file) do
    file
    |> Zipfile.csv(~c"request/commerce/bits/bits_acquired.csv")
  end
end
