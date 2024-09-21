defmodule TwitchStory.Games.Eurovision.Country.Apis.FlagPrivApi do
  @moduledoc false

  @behaviour TwitchStory.Games.Eurovision.Country.Apis.FlagApi

  @doc "Returns the flag of a country"
  @spec flag(String.t()) :: binary() | nil
  def flag(code) do
    "priv/static/images/flags/#{code}_64.png"
    |> File.read()
    |> case do
      {:ok, binary} -> binary
      {:error, _} -> <<>>
    end
  end
end
