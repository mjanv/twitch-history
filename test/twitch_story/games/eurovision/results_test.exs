defmodule TwitchStory.Games.Eurovision.ResultsTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Games.Eurovision.{Ceremony, Result}
  alias TwitchStory.Games.Eurovision.Repositories.Countries

  setup do
    user = user_fixture()

    {voter1, voter2, voter3} = {user_fixture(), user_fixture(), user_fixture()}

    {:ok, ceremony} =
      Ceremony.create(%{
        name: "ceremony",
        status: :started,
        countries: Countries.codes(),
        user_id: user.id
      })

    [
      %{country: "FR", points: 10, user_id: voter1.id},
      %{country: "FR", points: 5, user_id: voter2.id},
      %{country: "FR", points: 8, user_id: voter3.id},
      %{country: "SE", points: 12, user_id: voter1.id},
      %{country: "SE", points: 6, user_id: voter2.id},
      %{country: "SE", points: 4, user_id: voter3.id},
      %{country: "DE", points: 7, user_id: voter1.id},
      %{country: "DE", points: 3, user_id: voter2.id},
      %{country: "DE", points: 11, user_id: voter3.id},
      %{country: "IT", points: 9, user_id: voter1.id},
      %{country: "IT", points: 8, user_id: voter2.id},
      %{country: "IT", points: 5, user_id: voter3.id},
      %{country: "ES", points: 4, user_id: voter1.id},
      %{country: "ES", points: 7, user_id: voter2.id},
      %{country: "ES", points: 6, user_id: voter3.id}
    ]
    |> Enum.each(fn vote -> Ceremony.add_vote(ceremony, vote) end)

    {:ok, %{ceremony: Ceremony.get(ceremony.id)}}
  end

  test "The totals per ceremony can be calculated", %{ceremony: ceremony} do
    result = Ceremony.totals(ceremony)

    assert result == %{votes: 15, voters: 3, points: 105}
  end

  test "The leaderboard can be calculated", %{ceremony: ceremony} do
    result = Ceremony.leaderboard(ceremony)

    assert result == [
             %Result{country: "FR", points: 23, votes: 3},
             %Result{country: "IT", points: 22, votes: 3},
             %Result{country: "SE", points: 22, votes: 3},
             %Result{country: "DE", points: 21, votes: 3},
             %Result{country: "ES", points: 17, votes: 3}
           ]
  end

  test "The winner of a started ceremony cannot be found", %{ceremony: ceremony} do
    result = Ceremony.winner(ceremony)

    assert result == nil
  end

  test "The winner of a completed ceremony can be found", %{ceremony: ceremony} do
    {:ok, ceremony} = Ceremony.complete(ceremony)
    result = Ceremony.winner(ceremony)

    assert result == "FR"
  end

  test "A completed ceremony with no votes has no winner" do
    user = user_fixture()

    {:ok, ceremony} =
      Ceremony.create(%{
        name: "ceremony",
        status: :started,
        countries: Countries.codes(),
        user_id: user.id
      })

    {:ok, ceremony} = Ceremony.complete(ceremony)

    result = Ceremony.winner(ceremony)

    assert result == nil
  end
end
