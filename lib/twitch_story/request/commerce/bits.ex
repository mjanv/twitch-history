defmodule TwitchStory.Request.Commerce.Bits do
  @moduledoc false

  alias TwitchStory.Request.Zipfile

  def read(file) do
    file
    |> Zipfile.csv(~c"request/commerce/subs/subscriptions.csv")
  end
end
