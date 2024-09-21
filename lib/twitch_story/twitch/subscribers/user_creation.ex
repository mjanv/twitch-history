defmodule TwitchStory.Twitch.Subscribers.UserCreation do
  @moduledoc false

  use TwitchStory.EventSubscriber

  alias TwitchStory.Twitch.Workers.Channels.FollowedChannelsWorker

  def handle(%UserCreated{id: id}), do: FollowedChannelsWorker.start(id)
  def handle(_), do: :ok
end
