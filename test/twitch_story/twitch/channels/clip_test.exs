defmodule TwitchStory.Twitch.Channels.ClipTest do
  @moduledoc false

  use TwitchStory.DataCase

  alias TwitchStory.Twitch.Channels.Clip

  @valid_attrs %{
    twitch_id: "12345",
    video_id: "67890",
    title: "Test Clip",
    created_at: ~U[2023-09-01 12:00:00Z],
    broadcaster_id: "abc123",
    stats: %{
      duration: 30.5,
      view_count: 100
    },
    urls: %{
      url: "https://twitch.tv/testclip",
      embed_url: "https://twitch.tv/embed/testclip",
      thumbnail_url: "https://twitch.tv/thumbnail/testclip"
    }
  }

  test "create/1 with valid data creates a clip" do
    {:ok, %Clip{} = clip} = Clip.create(@valid_attrs)

    assert clip.twitch_id == "12345"
    assert clip.video_id == "67890"
    assert clip.title == "Test Clip"
    assert clip.created_at == ~U[2023-09-01 12:00:00Z]
    assert clip.broadcaster_id == "abc123"
    assert clip.stats.duration == 30.5
    assert clip.stats.view_count == 100
    assert clip.urls.url == "https://twitch.tv/testclip"
    assert clip.urls.embed_url == "https://twitch.tv/embed/testclip"
    assert clip.urls.thumbnail_url == "https://twitch.tv/thumbnail/testclip"
  end

  test "create/1 with existing data does not creates a clip" do
    {:ok, %Clip{}} = Clip.create(@valid_attrs)
    {:ok, %Clip{}} = Clip.create(@valid_attrs)
  end
end
