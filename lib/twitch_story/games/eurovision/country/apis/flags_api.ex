defmodule TwitchStory.Games.Eurovision.Country.Apis.FlagsApi do
  @moduledoc """
  Flags API

  The Flags API is used to retrieve the flag of a country from a web API. The API is available at https://flagsapi.com/. Each flag image is distributed under a MIT license.
  """

  @behaviour TwitchStory.Games.Eurovision.Country.Apis.FlagApi

  @doc "Returns the flag of a country"
  @spec flag(String.t()) :: binary() | nil
  def flag(code) do
    Req.new(retry: false)
    |> Req.get(url: "https://flagsapi.com/#{code}/shiny/64.png")
    |> case do
      {:ok, %Req.Response{status: 200, body: body}} when is_binary(body) -> body
      _ -> nil
    end
  end
end
