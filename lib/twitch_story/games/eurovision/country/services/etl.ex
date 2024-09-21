defmodule TwitchStory.Games.Eurovision.Country.Services.Etl do
  @moduledoc false

  alias TwitchStory.Games.Eurovision.Country

  @api Application.compile_env(:twitch_story, [:games, :eurovision, :apis, :flags])

  @doc "Load all countries"
  @spec extract_countries :: :ok
  def extract_countries do
    Enum.each(Country.Repo.all(), fn country ->
      country
      |> Map.put(:binary, @api.flag(country.code))
      |> Country.create()
    end)
  end
end
