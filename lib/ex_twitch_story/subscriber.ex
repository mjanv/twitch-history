defmodule Subscriber do
  @moduledoc false

  defmacro __using__(opts) do
    subcription = Keyword.get(opts, :subcription, UUID.uuid4())

    quote do
      use GenServer

      alias TwitchStory.EventStore

      def start_link do
        GenServer.start_link(__MODULE__, [])
      end

      def init(events) do
        {:ok, subscription} = EventStore.subscribe_to_all_streams(unquote(subcription), self())
        {:ok, %{subscription: subscription}}
      end

      def handle_info({:subscribed, _}, state) do
        {:noreply, state}
      end

      def handle_info({:events, events}, %{subscription: subscription} = state) do
        events
        |> Enum.map(fn event -> tap(event, &handle(&1)) end)
        |> then(fn events -> EventStore.ack(subscription, events) end)

        {:noreply, state}
      end

      def handle(_event), do: :ok

      defoverridable handle: 1
    end
  end
end
