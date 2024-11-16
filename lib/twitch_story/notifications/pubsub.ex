defmodule TwitchStory.Notifications.PubSub do
  @moduledoc false

  @behaviour TwitchStory.EventBus.Dispatcher

  alias TwitchStory.PubSub

  def dispatch(%EurovisionCeremonyCreated{id: id} = event),
    do: PubSub.broadcast("eurovision:#{id}", event)

  def dispatch(%EurovisionCeremonyStarted{id: id} = event),
    do: PubSub.broadcast("eurovision:#{id}", event)

  def dispatch(%EurovisionCeremonyPaused{id: id} = event),
    do: PubSub.broadcast("eurovision:#{id}", event)

  def dispatch(%EurovisionCeremonyCompleted{id: id} = event),
    do: PubSub.broadcast("eurovision:#{id}", event)

  def dispatch(%EurovisionCeremonyCancelled{id: id} = event),
    do: PubSub.broadcast("eurovision:#{id}", event)

  def dispatch(%EurovisionCeremonyDeleted{id: id} = event),
    do: PubSub.broadcast("eurovision:#{id}", event)

  def dispatch(_), do: :ok
end
