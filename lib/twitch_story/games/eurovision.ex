defmodule TwitchStory.Games.Eurovision do
  @moduledoc false

  alias TwitchStory.Games.Eurovision.Country

  defdelegate get_country(code), to: Country, as: :get

  @doc "Returns the list of valid points"
  @spec points(:asc | :desc) :: [integer()]
  def points(order \\ :asc)

  def points(:asc), do: [1, 2, 3, 4, 5, 6, 7, 8, 10, 12]
  def points(:desc), do: [12, 10, 8, 7, 6, 5, 4, 3, 2, 1]
end
