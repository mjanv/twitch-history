defmodule TwitchStory.Twitch.Histories.Commerce.Bits do
  @moduledoc false

  alias TwitchStory.Zipfile

  # "request/commerce/bits/bits_acquired.csv"
  # "request/commerce/bits/bits_cheered.csv"

  def read(file) do
    file
    |> Zipfile.csv("request/commerce/bits/bits_acquired.csv")
  end
end
