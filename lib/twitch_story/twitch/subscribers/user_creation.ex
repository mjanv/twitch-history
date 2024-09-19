defmodule TwitchStory.Twitch.Subscribers.UserCreation do
  @moduledoc false

  use GenServer

  alias TwitchStory.EventStore
  alias TwitchStory.Twitch.Workers.Channels.FollowedChannelsWorker

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, subscription} = EventStore.subscribe_to_all_streams(Atom.to_string(__MODULE__), self())
    {:ok, %{subscription: subscription}}
  end

  def handle_info({:subscribed, subscription}, %{subscription: subscription} = state) do
    Logger.info("[#{__MODULE__}] Subscribed to subscription #{inspect(subscription)}")
    {:noreply, state}
  end

  def handle_info({:events, events}, %{subscription: subscription} = state) do
    Logger.info("[#{__MODULE__}] Received #{length(events)} events")

    for event <- events do
      handle(event)
    end

    :ok = EventStore.ack(subscription, events)
    {:noreply, state}
  end

  def handle(%UserCreated{id: id}), do: FollowedChannelsWorker.start(id)
  def handle(_), do: :ok
end
