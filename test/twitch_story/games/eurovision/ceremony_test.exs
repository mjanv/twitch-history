defmodule TwitchStory.Games.Eurovision.CeremonyTest do
  use TwitchStory.DataCase

  import TwitchStory.AccountsFixtures

  alias TwitchStory.Games.Eurovision.Ceremony
  alias TwitchStory.Games.Eurovision.Repositories.Countries

  setup do
    user = user_fixture()

    ceremony_attrs = %{
      name: "ceremony",
      status: :started,
      countries: Countries.codes(),
      user_id: user.id
    }

    {:ok, %{ceremony_attrs: ceremony_attrs}}
  end

  test "A ceremony can be created", %{ceremony_attrs: ceremony_attrs} do
    {:ok, %Ceremony{} = ceremony} = Ceremony.create(ceremony_attrs)

    assert ceremony.name == "ceremony"
    assert ceremony.status == :started
    assert ceremony.countries == ["FR", "SW", "DE", "ES", "IT"]
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
end
