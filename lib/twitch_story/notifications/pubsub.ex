defmodule TwitchStory.Notifications.PubSub do
  @moduledoc false

  @behaviour ExTwitchStory.EventBus.Dispatcher

  def dispatch(event) do
    Phoenix.PubSub.broadcast(TwitchStory.PubSub, "notifications:events", event)
  end
end
