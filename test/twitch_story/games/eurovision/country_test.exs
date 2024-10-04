defmodule TwitchStory.Games.Eurovision.CountryTest do
  use TwitchStory.DataCase

  alias TwitchStory.Games.Eurovision.Country

  describe "create/1" do
    test "creates a new country" do
      country = %{name: "France", code: "FR"}

      {:ok, %Country{} = country} = Country.create(country)

      assert country.name == "France"
      assert country.code == "FR"
      assert country.binary == nil
    end

    test "updates an existing country" do
      country = %{name: "France", code: "FR", binary: "a"}

      {:ok, %Country{} = country} = Country.create(country)

      assert country.name == "France"
      assert country.code == "FR"
      assert country.binary == "a"

      country = %{name: "France", code: "FR", binary: "b"}

      {:ok, %Country{} = country} = Country.create(country)

      assert country.name == "France"
      assert country.code == "FR"
      assert country.binary == "b"
    end

    test "does not create a country with invalid data" do
      country = %{name: nil, code: "XX"}

      assert {:error, %Ecto.Changeset{}} = Country.create(country)
    end
  end

  describe "get/1" do
    test "returns the country for a given code" do
      Country.create(%{name: "France", code: "FR", binary: "a"})

      country = Country.get("FR")

      assert country.name == "France"
      assert country.code == "FR"
      assert country.binary == "a"
    end

    test "returns nil if the country does not exist" do
      assert Country.get("XX") == nil
    end
  end
end
