defmodule TwitchStory.TwitchFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwitchStory.Twitch` context.
  """

  alias TwitchStory.Twitch.Channels

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      broadcaster_id: UUID.uuid4(),
      broadcaster_language: Enum.random(["fr", "en"]),
      broadcaster_login: "some broadcaster_login",
      broadcaster_name: "some broadcaster_name",
      description: "some description",
      tags: ["option1", "option2"],
      thumbnail: "some thumbnail",
      thumbnail_url: "some thumbnail_url"
    })
    |> Channels.Channel.create()
    |> then(fn {:ok, channel} -> channel end)
  end

  @doc """
  Generate a emote.
  """
  def emote_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      id: "some id",
      name: "some name",
      emote_set_id: "some emote_set_id",
      formats: ["option1", "option2"],
      scales: ["option1", "option2"],
      themes: ["option1", "option2"],
      tier: 1,
      thumbnail_url: "some thumbnail_url",
      channel_id: UUID.uuid4()
    })
    |> Channels.Emote.create()
    |> then(fn {:ok, emote} -> emote end)
  end
end
