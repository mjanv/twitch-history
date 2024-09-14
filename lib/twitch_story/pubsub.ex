defmodule TwitchStory.PubSub do
  @moduledoc false

  @pubsub TwitchStory.PubSub

  @type topic() :: String.t()
  @type event() :: atom() | {atom(), any()}

  @doc "Broadcast events on the pubsub broker"
  @spec broadcast(String.t(), event()) :: :ok
  def broadcast(topic, event) do
    Phoenix.PubSub.broadcast(@pubsub, topic, event)
  end

  @doc "Subscribe to a topic of the pubsub broker"
  @spec subscribe(topic()) :: :ok
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(@pubsub, topic)
  end
end
