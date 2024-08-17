defmodule TwitchStory.Games.EurovisionTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Games.Eurovision.{Ceremony, Vote}

  setup do
    user = user_fixture()

    ceremony = %{
      name: "a",
      countries: ["France", "Sweden", "Germany", "Italy", "Spain"],
      user_id: user.id
    }

    {:ok, %{ceremony: ceremony}}
  end

  test "A ceremony can be created", %{ceremony: ceremony} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony)

    assert ceremony.name == "a"
    assert ceremony.countries == ["France", "Sweden", "Germany", "Italy", "Spain"]
  end

  test "A vote can be added to a ceremony", %{ceremony: ceremony} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony)

    vote = %{country: "France", points: 4, user_id: voter.id}

    {:ok, %Vote{} = vote} = Ceremony.add_vote(ceremony, vote)

    assert vote.country == "France"
    assert vote.points == 4
  end

  test "A vote cannot be added to a ceremony if the country is unknown", %{ceremony: ceremony} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony)

    vote = %{country: "USA", points: 4, user_id: voter.id}

    {:error, changeset} = Ceremony.add_vote(ceremony, vote)

    assert changeset.errors == [country: {"is not part of the countries in the ceremony", []}]
  end

  test "The list of votes of a ceremony can be listed", %{ceremony: ceremony} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony)

    vote_fr = %{country: "France", points: 4, user_id: voter.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_fr)

    vote_sw = %{country: "Sweden", points: 12, user_id: voter.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_sw)

    [vote_fr, vote_sw] = Ceremony.votes(ceremony)

    assert vote_fr.country == "France"
    assert vote_fr.points == 4

    assert vote_sw.country == "Sweden"
    assert vote_sw.points == 12
  end

  test "The list of voters of a ceremony can be listed", %{ceremony: ceremony} do
    voter_a = user_fixture()
    voter_b = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony)

    vote_fr = %{country: "France", points: 4, user_id: voter_a.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_fr)

    vote_sw = %{country: "Sweden", points: 12, user_id: voter_b.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_sw)

    [voter_1, voter_2] = Ceremony.voters(ceremony)

    assert voter_a.id == voter_1.id
    assert voter_b.id == voter_2.id
  end

  test "The total number of points per country can be calculated", %{ceremony: ceremony} do
    voter1 = user_fixture()
    voter2 = user_fixture()
    voter3 = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony)

    [
      %{country: "France", points: 10, user_id: voter1.id},
      %{country: "France", points: 5, user_id: voter2.id},
      %{country: "France", points: 8, user_id: voter3.id},
      %{country: "Sweden", points: 12, user_id: voter1.id},
      %{country: "Sweden", points: 6, user_id: voter2.id},
      %{country: "Sweden", points: 4, user_id: voter3.id},
      %{country: "Germany", points: 7, user_id: voter1.id},
      %{country: "Germany", points: 3, user_id: voter2.id},
      %{country: "Germany", points: 11, user_id: voter3.id},
      %{country: "Italy", points: 9, user_id: voter1.id},
      %{country: "Italy", points: 8, user_id: voter2.id},
      %{country: "Italy", points: 5, user_id: voter3.id},
      %{country: "Spain", points: 4, user_id: voter1.id},
      %{country: "Spain", points: 7, user_id: voter2.id},
      %{country: "Spain", points: 6, user_id: voter3.id}
    ]
    |> Enum.each(fn vote -> {:ok, _} = Ceremony.add_vote(ceremony, vote) end)

    result = Ceremony.total_points_per_country(ceremony)

    expected_result = [
      %{country: "France", total: 23},
      %{country: "Sweden", total: 22},
      %{country: "Germany", total: 21},
      %{country: "Italy", total: 22},
      %{country: "Spain", total: 17}
    ]

    assert Enum.sort_by(result, & &1.country) == Enum.sort_by(expected_result, & &1.country)
  end
end
