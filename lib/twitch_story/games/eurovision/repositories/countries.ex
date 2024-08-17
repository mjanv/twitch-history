defmodule TwitchStory.Games.Eurovision.Repositories.Countries do
  @moduledoc false

  def all do
    [
      %{name: "France", code: "FR"},
      %{name: "Sweden", code: "SW"},
      %{name: "Germany", code: "DE"},
      %{name: "Spain", code: "ES"},
      %{name: "Italy", code: "IT"}
    ]
  end

  def codes, do: all() |> Enum.map(& &1.code)
end
