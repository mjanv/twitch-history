defmodule TwitchStory.TwitchTest do
  @moduledoc false

  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Emote

  import TwitchStory.TwitchFixtures

  @invalid_attrs %{
    formats: nil,
    name: nil,
    emote_set_id: nil,
    scales: nil,
    themes: nil,
    thumbnail_url: nil,
    thumbnail: nil
  }

  test "list/0 returns all emotes" do
    emote = emote_fixture()
    assert Emote.list() == [emote]
  end

  test "get!/1 returns the emote with given id" do
    emote = emote_fixture()
    assert Emote.get!(emote.id) == emote
  end

  test "create/1 with valid data creates a emote" do
    valid_attrs = %{
      formats: ["option1", "option2"],
      name: "some name",
      emote_set_id: "some emote_set_id",
      scales: ["option1", "option2"],
      themes: ["option1", "option2"],
      thumbnail_url: "some thumbnail_url",
      thumbnail: "some thumbnail"
    }

    assert {:ok, %Emote{} = emote} = Emote.create(valid_attrs)
    assert emote.formats == ["option1", "option2"]
    assert emote.name == "some name"
    assert emote.emote_set_id == "some emote_set_id"
    assert emote.scales == ["option1", "option2"]
    assert emote.themes == ["option1", "option2"]
    assert emote.thumbnail_url == "some thumbnail_url"
    assert emote.thumbnail == "some thumbnail"
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Emote.create(@invalid_attrs)
  end

  test "update/2 with valid data updates the emote" do
    emote = emote_fixture()

    update_attrs = %{
      formats: ["option1"],
      name: "some updated name",
      emote_set_id: "some updated emote_set_id",
      scales: ["option1"],
      themes: ["option1"],
      thumbnail_url: "some updated thumbnail_url",
      thumbnail: "some updated thumbnail"
    }

    assert {:ok, %Emote{} = emote} = Emote.update(emote, update_attrs)
    assert emote.formats == ["option1"]
    assert emote.name == "some updated name"
    assert emote.emote_set_id == "some updated emote_set_id"
    assert emote.scales == ["option1"]
    assert emote.themes == ["option1"]
    assert emote.thumbnail_url == "some updated thumbnail_url"
    assert emote.thumbnail == "some updated thumbnail"
  end

  test "update/2 with invalid data returns error changeset" do
    emote = emote_fixture()
    assert {:error, %Ecto.Changeset{}} = Emote.update(emote, @invalid_attrs)
    assert emote == Emote.get!(emote.id)
  end

  test "delete/1 deletes the emote" do
    emote = emote_fixture()
    assert {:ok, %Emote{}} = Emote.delete(emote)
    assert_raise Ecto.NoResultsError, fn -> Emote.get!(emote.id) end
  end

  test "change/1 returns a emote changeset" do
    emote = emote_fixture()
    assert %Ecto.Changeset{} = Emote.change(emote)
  end
end
