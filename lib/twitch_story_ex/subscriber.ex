defmodule TwitchStory.EventSubscriber do
  @moduledoc """
  Event Store subscriber

  Using this behaviour, you can subscribe to all event registered in the EventStore. The subscription ID is automatically generated if none is provided. Two differents subcribeers should have different subscription IDs.

  To define the behaviour of your subscriber, override the `handle/1` function. It takes an event as argument and should return `:ok` if the event is handled or `:error` if it cannot be handled.
  """

  defmacro __using__(opts) do
    subcription = Keyword.get(opts, :subcription, UUID.uuid4())

    quote do
      use GenServer

      alias TwitchStory.EventStore

      require Logger

      def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(events) do
        {:ok, subscription} = EventStore.subscribe_to_all_streams(unquote(subcription), self())
        {:ok, %{subscription: subscription}}
      end

      def handle_info({:subscribed, subscription}, state) do
        Logger.info("[#{__MODULE__}] Subscribed to subscription #{inspect(subscription)}")

        {:noreply, state}
      end

      def handle_info({:events, events}, %{subscription: subscription} = state) do
        events
        |> tap(fn events -> Logger.info("[#{__MODULE__}] Received #{length(events)} events") end)
        |> Enum.map(fn event -> tap(event, &handle(&1)) end)
        |> then(fn events -> EventStore.ack(subscription, events) end)
        |> then(fn _ -> {:noreply, state} end)
      end

      def handle(_event), do: :ok

      defoverridable handle: 1
    end
  end
end
