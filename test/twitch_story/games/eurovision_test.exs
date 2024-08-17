defmodule TwitchStory.Games.EurovisionTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Games.Eurovision.{Ceremony, Result, Vote}

  setup do
    user = user_fixture()

    ceremony_attrs = %{
      name: "ceremony",
      status: :started,
      countries: ["France", "Sweden", "Germany", "Italy", "Spain"],
      user_id: user.id
    }

    {:ok, %{ceremony_attrs: ceremony_attrs}}
  end

  test "A ceremony can be created", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    assert ceremony.name == "ceremony"
    assert ceremony.status == :started
    assert ceremony.countries == ["France", "Sweden", "Germany", "Italy", "Spain"]
  end

  test "A ceremony can be completed", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, ceremony} = Ceremony.complete(ceremony)

    assert ceremony.status == :completed
  end

  test "A ceremony can be cancelled", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, ceremony} = Ceremony.cancel(ceremony)

    assert ceremony.status == :cancelled
  end

  test "The list of all ceremonies can be listed" do
    user = user_fixture()

    [
      %{name: "a", status: :started, countries: [], user_id: user.id},
      %{name: "b", status: :started, countries: [], user_id: user.id},
      %{name: "c", status: :started, countries: [], user_id: user.id}
    ]
    |> Enum.each(fn ceremony -> Ceremony.create(ceremony) end)

    [%Ceremony{} = a, %Ceremony{} = b, %Ceremony{} = c] = Ceremony.all(user_id: user.id)

    assert a.name == "a"
    assert a.countries == []
    assert b.name == "b"
    assert b.countries == []
    assert c.name == "c"
    assert c.countries == []
  end

  test "A vote can be added to a ceremony", %{ceremony_attrs: ceremony_attrs} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

    vote = %{country: "France", points: 4, user_id: voter.id}

    {:ok, %Vote{} = vote} = Ceremony.add_vote(ceremony, vote)

    assert vote.country == "France"
    assert vote.points == 4
  end

  test "Multiple votes can be added to a ceremony", %{ceremony_attrs: ceremony_attrs} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

    votes = [
      %{country: "France", points: 4, user_id: voter.id},
      %{country: "Sweden", points: 12, user_id: voter.id}
    ]

    {:ok, [%Vote{} = vote1, %Vote{} = vote2]} = Ceremony.add_votes(ceremony, votes)

    assert vote1.country == "France"
    assert vote1.points == 4

    assert vote2.country == "Sweden"
    assert vote2.points == 12
  end

  test "A vote cannot be added to a ceremony if the country is unknown", %{
    ceremony_attrs: ceremony_attrs
  } do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

    vote = %{country: "USA", points: 4, user_id: voter.id}

    {:error, changeset} = Ceremony.add_vote(ceremony, vote)

    assert changeset.errors == [country: {"is not part of the countries in the ceremony", []}]
  end

  test "The list of votes of a ceremony can be listed", %{ceremony_attrs: ceremony_attrs} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

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

  test "The list of voters of a ceremony can be listed", %{ceremony_attrs: ceremony_attrs} do
    voter_a = user_fixture()
    voter_b = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

    vote_fr = %{country: "France", points: 4, user_id: voter_a.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_fr)

    vote_sw = %{country: "Sweden", points: 12, user_id: voter_b.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_sw)

    [voter_1, voter_2] = Ceremony.voters(ceremony)

    assert voter_a.id == voter_1.id
    assert voter_b.id == voter_2.id
  end

  test "The list of a user votes of a ceremony can be listed", %{ceremony_attrs: ceremony_attrs} do
    voter1 = user_fixture()
    voter2 = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "France", points: 4, user_id: voter1.id})

    {:ok, vote_sw} =
      Ceremony.add_vote(ceremony, %{country: "Sweden", points: 10, user_id: voter1.id})

    {:ok, _} = Ceremony.add_vote(ceremony, %{country: "Germany", points: 8, user_id: voter2.id})

    all_votes = Ceremony.votes(ceremony)
    [vote1, vote2] = Ceremony.user_votes(ceremony, voter1)

    assert length(all_votes) == 3
    assert vote_fr == vote1
    assert vote_sw == vote2
  end

  test "A vote can be modified for the same usesr and country", %{ceremony_attrs: ceremony_attrs} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "France", points: 4, user_id: voter.id})

    {:ok, new_vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "France", points: 12, user_id: voter.id})

    votes = Ceremony.user_votes(ceremony, voter)

    assert length(votes) == 1
    assert vote_fr.id == new_vote_fr.id
    assert vote_fr.country == new_vote_fr.country
    assert {vote_fr.points, new_vote_fr.points} == {4, 12}
  end

  test "A vote can be deleted", %{ceremony_attrs: ceremony_attrs} do
    voter = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "France", points: 4, user_id: voter.id})

    {:ok, _} = Ceremony.delete_vote(ceremony, vote_fr)

    votes = Ceremony.user_votes(ceremony, voter)

    assert Enum.empty?(votes)
  end

  setup %{ceremony_attrs: ceremony_attrs} do
    voter1 = user_fixture()
    voter2 = user_fixture()
    voter3 = user_fixture()

    {:ok, ceremony} = Ceremony.create(ceremony_attrs)

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

    {:ok, %{ceremony: ceremony}}
  end

  test "The totals per ceremony can be calculated", %{ceremony: ceremony} do
    result = Ceremony.totals(ceremony)

    assert result == %{votes: 15, points: 105}
  end

  test "The results per country can be calculated", %{ceremony: ceremony} do
    result = Ceremony.results(ceremony)

    assert result == [
             %Result{country: "France", points: 23, votes: 3},
             %Result{country: "Sweden", points: 22, votes: 3},
             %Result{country: "Italy", points: 22, votes: 3},
             %Result{country: "Germany", points: 21, votes: 3},
             %Result{country: "Spain", points: 17, votes: 3}
           ]
  end

  test "The winner of a started ceremony cannot be found", %{ceremony: ceremony} do
    result = Ceremony.winner(ceremony)

    assert result == nil
  end

  test "The winner of a completed ceremony can be found", %{ceremony: ceremony} do
    {:ok, ceremony} = Ceremony.complete(ceremony)
    result = Ceremony.winner(ceremony)

    assert result == "France"
  end
end
