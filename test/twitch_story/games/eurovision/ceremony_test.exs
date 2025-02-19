defmodule TwitchStory.Games.Eurovision.CeremonyTest do
  use TwitchStory.DataCase

  alias TwitchStory.Games.Eurovision.Ceremony
  alias TwitchStory.Games.Eurovision.Country

  setup do
    user = user_fixture()

    ceremony_attrs = %{
      name: "ceremony",
      countries: Country.Repo.codes(),
      user_id: user.id
    }

    {:ok, %{ceremony_attrs: ceremony_attrs}}
  end

  test "A ceremony can be created", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    event?(%EurovisionCeremonyCreated{id: ceremony.id})

    assert ceremony.name == "ceremony"
    assert ceremony.status == :created

    assert ceremony.countries == [
             "AL",
             "AD",
             "AM",
             "AU",
             "AT",
             "AZ",
             "BY",
             "BE",
             "BA",
             "BG",
             "HR",
             "CY",
             "CZ",
             "DK",
             "EE",
             "FI",
             "FR",
             "GE",
             "DE",
             "GR",
             "HU",
             "IS",
             "IE",
             "IL",
             "IT",
             "KZ",
             "LV",
             "LI",
             "LT",
             "LU",
             "MT",
             "MD",
             "MC",
             "ME",
             "NL",
             "MK",
             "NO",
             "PL",
             "PT",
             "RO",
             "SM",
             "RS",
             "SK",
             "SI",
             "ES",
             "SE",
             "CH",
             "TR",
             "UA",
             "GB"
           ]
  end

  test "A ceremony can be started", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, ceremony} = Ceremony.start(ceremony)

    event?(%EurovisionCeremonyStarted{id: ceremony.id})

    assert ceremony.status == :started
  end

  test "A ceremony can be paused (and restarted)", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, a} = Ceremony.start(ceremony)
    {:ok, b} = Ceremony.pause(a)
    {:ok, c} = Ceremony.start(b)

    stream?([
      %EurovisionCeremonyCreated{id: ceremony.id},
      %EurovisionCeremonyStarted{id: ceremony.id},
      %EurovisionCeremonyPaused{id: ceremony.id},
      %EurovisionCeremonyStarted{id: ceremony.id}
    ])

    assert {a.status, b.status, c.status} == {:started, :paused, :started}
  end

  test "A ceremony can be completed", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, ceremony} = Ceremony.complete(ceremony)

    event?(%EurovisionCeremonyCompleted{id: ceremony.id})

    assert ceremony.status == :completed
  end

  test "A completed ceremony cannot be restarted", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, ceremony} = Ceremony.complete(ceremony)
    {:error, reason} = Ceremony.start(ceremony)

    assert Ceremony.get(ceremony.id).status == :completed
    assert reason == :already_completed
  end

  test "A ceremony can be cancelled", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, ceremony} = Ceremony.cancel(ceremony)

    event?(%EurovisionCeremonyCancelled{id: ceremony.id})

    assert ceremony.status == :cancelled
  end

  test "A cancelled ceremony cannot be restarted", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, ceremony} = Ceremony.cancel(ceremony)
    {:error, reason} = Ceremony.start(ceremony)

    assert Ceremony.get(ceremony.id).status == :cancelled
    assert reason == :already_cancelled
  end

  test "A ceremony can be deleted", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    {:ok, _} =
      Ceremony.add_vote(ceremony, %{country: "FR", points: 4, user_id: user_fixture().id})

    {:ok, _} = Ceremony.delete(ceremony)

    event?(%EurovisionCeremonyDeleted{id: ceremony.id})

    assert Ceremony.get(ceremony.id) == nil
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
end
