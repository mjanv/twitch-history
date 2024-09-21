defmodule TwitchStory.Games.Eurovision.Ceremony.Services.Votes do
  @moduledoc false

  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Ceremony

  @doc """
  Initialize votes for a given user

  Votes are initialized to zero for each country in the ceremony.
  """
  @spec init_votes(Ceremony.t(), User.t()) :: {:ok, [Ceremony.Vote.t()]} | {:error, any()}
  def init_votes(%Ceremony{countries: countries} = ceremony, %User{id: id}) do
    countries
    |> Enum.map(fn country -> %{country: country, points: 0, user_id: id} end)
    |> then(fn votes -> Ceremony.add_votes(ceremony, votes) end)
  end
end
