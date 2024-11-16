defmodule TwitchStory.EventSubscriber do
  @moduledoc false

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
