defmodule TwitchStory.Twitch do
  @moduledoc false

  alias TwitchStory.Twitch.{Api, Channels}

  defdelegate channels, to: Channels.Channel, as: :all
  def channel_changeset, do: Channels.Channel.change(%Channels.Channel{})

  def create_channel(name) do
    with {:ok, broadcaster_id} <- Api.reverse_search(name),
         {:ok, attrs} <- Api.channel(broadcaster_id),
         {:ok, channel} <- Channels.Channel.create(attrs) do
      {:ok, channel}
    else
      {:error, _} -> {:error, "Cannot create channel"}
    end
  end
end
