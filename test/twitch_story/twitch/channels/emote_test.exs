defmodule TwitchStory.Twitch.Channels.EmoteTest do
  @moduledoc false

  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Channels.Emote

  import TwitchStory.TwitchFixtures

  @invalid_attrs %{
    formats: nil,
    name: nil,
    emote_set_id: nil,
    scales: nil,
    themes: nil,
    tier: nil,
    thumbnail_url: nil
  }

  setup do
    channel = channel_fixture()
    emote = emote_fixture(%{channel_id: channel.id})
    {:ok, channel: channel, emote: emote}
  end

  test "list/0 returns all emotes", %{emote: emote} do
    assert Emote.list() == [emote]
  end

  test "get!/1 returns the emote with given id", %{emote: emote} do
    assert Emote.get(id: emote.id) == emote
  end

  test "create/1 with valid data creates a emote", %{channel: channel} do
    valid_attrs = %{
      formats: ["option1", "option2"],
      name: "some name",
      channel_id: channel.id,
      emote_set_id: "some emote_set_id",
      scales: ["option1", "option2"],
      themes: ["option1", "option2"],
      tier: 0,
      thumbnail_url: "some thumbnail_url"
    }

    {:ok, %Emote{} = emote} = Emote.create(valid_attrs)

    assert emote.formats == ["option1", "option2"]
    assert emote.name == "some name"
    assert emote.emote_set_id == "some emote_set_id"
    assert emote.scales == ["option1", "option2"]
    assert emote.themes == ["option1", "option2"]
    assert emote.tier == 0
    assert emote.thumbnail_url == "some thumbnail_url"
  end

  test "create/1 with invalid data returns error changeset" do
    {:error, %Ecto.Changeset{}} = Emote.create(@invalid_attrs)
  end

  test "update/2 with valid data updates the emote", %{channel: channel} do
    emote = emote_fixture(%{channel_id: channel.id})

    update_attrs = %{
      formats: ["option1"],
      name: "some updated name",
      emote_set_id: "some updated emote_set_id",
      scales: ["option1"],
      themes: ["option1"],
      thumbnail_url: "some updated thumbnail_url"
    }

    assert {:ok, %Emote{} = emote} = Emote.update(emote, update_attrs)
    assert emote.formats == ["option1"]
    assert emote.name == "some updated name"
    assert emote.emote_set_id == "some updated emote_set_id"
    assert emote.scales == ["option1"]
    assert emote.themes == ["option1"]
    assert emote.tier == 1
    assert emote.thumbnail_url == "some updated thumbnail_url"
  end

  test "update/2 with invalid data returns error changeset", %{emote: emote} do
    assert {:error, %Ecto.Changeset{}} = Emote.update(emote, @invalid_attrs)
    assert emote == Emote.get(id: emote.id)
  end

  test "delete/1 deletes the emote", %{emote: emote} do
    assert {:ok, %Emote{}} = Emote.delete(emote)
    assert Emote.get(id: emote.id) == nil
  end

  test "from_api/1 returns emotes attributes from api data" do
    api_emote = %{
      name: "channelEmotename",
      format: ["static"],
      template:
        "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}",
      channel_id: "656252271",
      emote_id: "emotesv2_b0683f8d7fda4e3aa41964e12aa034db",
      emote_set_id: "304055037",
      scale: ["1.0", "2.0", "3.0"],
      emote_type: "subscriptions",
      theme_mode: ["light", "dark"],
      tier: "1000"
    }

    emote_attrs = Emote.from_api(api_emote)

    assert emote_attrs == %{
             emote_id: "emotesv2_b0683f8d7fda4e3aa41964e12aa034db",
             name: "channelEmotename",
             channel_id: "656252271",
             emote_set_id: "304055037",
             formats: ["static"],
             scales: ["1.0", "2.0", "3.0"],
             themes: ["light", "dark"],
             tier: 1000,
             thumbnail_url:
               "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_b0683f8d7fda4e3aa41964e12aa034db/static/light/3.0"
           }
  end
end
