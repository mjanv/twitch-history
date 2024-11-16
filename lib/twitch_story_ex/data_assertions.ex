defmodule TwitchStory.DataAssertions do
  @moduledoc false

  @doc """
  Asserts the event store has received on a stream the exact list of events

  Stream UUID is extracted from the ID of the first event.
  """
  defmacro stream?(events) do
    quote do
      {:ok, events} = TwitchStory.EventStore.all(hd(unquote(events)).id)
      assert events == unquote(events)
    end
  end

  @doc """
  Assert that an event has been received on a stream by the event store

  Stream UUID is extracted from the ID of the event.
  """
  defmacro event?(event) do
    quote do
      {:ok, events} = TwitchStory.EventStore.all(unquote(event).id)
      assert unquote(event) in events
    end
  end

  @doc """
  Assert that no event has been received on a stream by the event store

  Stream UUID is extracted from the ID of the event.
  """
  defmacro empty_stream?(event) do
    quote do
      {:ok, events} = TwitchStory.EventStore.all(unquote(event).id)
      assert Enum.empty?(events)
    end
  end
end
