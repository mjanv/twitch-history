defmodule TwitchStory.Games.Eurovision.CountryTest do
  @moduledoc false

  use ExUnit.Case

  alias TwitchStory.Games.Eurovision.Country

  test "?" do
    countries = Country.all()

    assert countries == [
             %Country{name: "France", code: "FR", image: "https://flagsapi.com/FR/shiny/64.png"},
             %Country{name: "Sweden", code: "SW", image: "https://flagsapi.com/SW/shiny/64.png"},
             %Country{name: "Germany", code: "DE", image: "https://flagsapi.com/DE/shiny/64.png"},
             %Country{name: "Spain", code: "ES", image: "https://flagsapi.com/ES/shiny/64.png"},
             %Country{name: "Italy", code: "IT", image: "https://flagsapi.com/IT/shiny/64.png"}
           ]
  end
end
