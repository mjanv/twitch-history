defmodule TwitchStory.Games.Eurovision.Ceremony.Services.VotesTest do
  use TwitchStory.DataCase

  alias TwitchStory.Games.Eurovision.Ceremony
  alias TwitchStory.Games.Eurovision.Ceremony.Services
  alias TwitchStory.Games.Eurovision.Country

  setup do
    user = user_fixture()

    attrs = %{
      name: "ceremony",
      status: :started,
      countries: Country.Repo.codes(),
      user_id: user.id
    }

    {:ok, ceremony} = Ceremony.create(attrs)

    {:ok, %{ceremony: ceremony}}
  end

  test "User votes can be initialized with all ceremony countries and points to 0", %{
    ceremony: ceremony
  } do
    voter = user_fixture()

    {:ok, _} = Services.Votes.init_votes(ceremony, voter)
    votes = Ceremony.user_votes(ceremony, voter)

    assert length(votes) == length(ceremony.countries)

    for vote <- votes do
      assert vote.country in ceremony.countries
      assert vote.points == 0
    end
  end
end
