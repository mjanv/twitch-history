defmodule TwitchStory.Games.Eurovision.Country.Apis.FlagApi do
  @moduledoc false

  @type code() :: String.t()

  @callback flag(code()) :: binary() | nil
end
