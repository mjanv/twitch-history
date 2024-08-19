defmodule TwitchStory.Games.Eurovision.VoteTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Games.Eurovision.{Ceremony, Vote}
  alias TwitchStory.Games.Eurovision.Repositories.Countries

  setup do
    user = user_fixture()

    attrs = %{
      name: "ceremony",
      status: :started,
      countries: Countries.codes(),
      user_id: user.id
    }

    {:ok, ceremony} = Ceremony.create(attrs)

    {:ok, %{ceremony: ceremony}}
  end

  test "A vote can be added to a ceremony", %{ceremony: ceremony} do
    voter = user_fixture()

    vote = %{country: "FR", points: 4, user_id: voter.id}

    {:ok, %Vote{} = vote} = Ceremony.add_vote(ceremony, vote)

    assert vote.country == "FR"
    assert vote.points == 4
  end

  test "A vote can be updated to a ceremony", %{ceremony: ceremony} do
    voter = user_fixture()

    vote = %{country: "FR", points: 4, user_id: voter.id}
    {:ok, %Vote{} = vote1} = Ceremony.add_vote(ceremony, vote)

    vote = %{country: "FR", points: 12, user_id: voter.id}
    {:ok, %Vote{} = vote2} = Ceremony.add_vote(ceremony, vote)

    assert vote1.id == vote2.id

    assert vote1.country == "FR"
    assert vote1.points == 4

    assert vote2.country == "FR"
    assert vote2.points == 12
  end

  test "Multiple votes can be added to a ceremony", %{ceremony: ceremony} do
    voter = user_fixture()

    votes = [
      %{country: "FR", points: 4, user_id: voter.id},
      %{country: "SE", points: 12, user_id: voter.id}
    ]

    {:ok, [%Vote{} = vote1, %Vote{} = vote2]} = Ceremony.add_votes(ceremony, votes)

    assert vote1.country == "FR"
    assert vote1.points == 4

    assert vote2.country == "SE"
    assert vote2.points == 12
  end

  test "Multiple votes can be updated to a ceremony", %{ceremony: ceremony} do
    voter = user_fixture()

    votes = [
      %{country: "FR", points: 4, user_id: voter.id},
      %{country: "SE", points: 12, user_id: voter.id}
    ]

    {:ok, [%Vote{} = vote1, %Vote{} = vote2]} = Ceremony.add_votes(ceremony, votes)

    votes = [
      %{country: "FR", points: 12, user_id: voter.id},
      %{country: "SE", points: 4, user_id: voter.id}
    ]

    {:ok, [%Vote{} = vote3, %Vote{} = vote4]} = Ceremony.add_votes(ceremony, votes)

    assert vote1.id == vote3.id
    assert vote2.id == vote4.id

    assert vote1.country == "FR"
    assert vote1.points == 4

    assert vote2.country == "SE"
    assert vote2.points == 12

    assert vote3.country == "FR"
    assert vote3.points == 12

    assert vote4.country == "SE"
    assert vote4.points == 4
  end

  test "A vote cannot be added to a ceremony if the country is unknown", %{
    ceremony: ceremony
  } do
    voter = user_fixture()

    vote = %{country: "USA", points: 4, user_id: voter.id}

    {:error, changeset} = Ceremony.add_vote(ceremony, vote)

    assert changeset.errors == [country: {"is not part of the countries in the ceremony", []}]
  end

  test "The list of votes of a ceremony can be listed", %{ceremony: ceremony} do
    voter = user_fixture()

    vote_fr = %{country: "FR", points: 4, user_id: voter.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_fr)

    vote_sw = %{country: "SE", points: 12, user_id: voter.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_sw)

    [vote_fr, vote_sw] = Ceremony.votes(ceremony)

    assert vote_fr.country == "FR"
    assert vote_fr.points == 4

    assert vote_sw.country == "SE"
    assert vote_sw.points == 12
  end

  test "The list of voters of a ceremony can be listed", %{ceremony: ceremony} do
    voter_a = user_fixture()
    voter_b = user_fixture()

    vote_fr = %{country: "FR", points: 4, user_id: voter_a.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_fr)

    vote_sw = %{country: "SE", points: 12, user_id: voter_b.id}
    {:ok, _} = Ceremony.add_vote(ceremony, vote_sw)

    [voter_1, voter_2] = Ceremony.voters(ceremony)

    assert voter_a.id == voter_1.id
    assert voter_b.id == voter_2.id
  end

  test "The list of a user votes of a ceremony can be listed", %{ceremony: ceremony} do
    voter1 = user_fixture()
    voter2 = user_fixture()

    {:ok, vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "FR", points: 4, user_id: voter1.id})

    {:ok, vote_sw} =
      Ceremony.add_vote(ceremony, %{country: "SE", points: 10, user_id: voter1.id})

    {:ok, _} = Ceremony.add_vote(ceremony, %{country: "DE", points: 8, user_id: voter2.id})

    all_votes = Ceremony.votes(ceremony)
    [vote1, vote2] = Ceremony.user_votes(ceremony, voter1)

    assert length(all_votes) == 3
    assert vote_fr == vote1
    assert vote_sw == vote2
  end

  test "A vote can be modified for the same user and country", %{ceremony: ceremony} do
    voter = user_fixture()

    {:ok, vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "FR", points: 4, user_id: voter.id})

    {:ok, new_vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "FR", points: 12, user_id: voter.id})

    votes = Ceremony.user_votes(ceremony, voter)

    assert length(votes) == 1
    assert vote_fr.id == new_vote_fr.id
    assert vote_fr.country == new_vote_fr.country
    assert {vote_fr.points, new_vote_fr.points} == {4, 12}
  end

  test "A vote can be deleted", %{ceremony: ceremony} do
    voter = user_fixture()

    {:ok, vote_fr} =
      Ceremony.add_vote(ceremony, %{country: "FR", points: 4, user_id: voter.id})

    {:ok, _} = Ceremony.delete_vote(ceremony, vote_fr)

    votes = Ceremony.user_votes(ceremony, voter)

    assert Enum.empty?(votes)
  end

  test "User votes can be initialized with all ceremony countries and points to 0", %{
    ceremony: ceremony
  } do
    voter = user_fixture()

    {:ok, _} = Ceremony.init_votes(ceremony, voter)
    votes = Ceremony.user_votes(ceremony, voter)

    assert length(votes) == length(ceremony.countries)

    for vote <- votes do
      assert vote.country in ceremony.countries
      assert vote.points == 0
    end
  end
end
