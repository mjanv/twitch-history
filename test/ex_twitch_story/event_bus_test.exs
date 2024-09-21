defmodule ExTwitchStory.EventBusTest do
  use ExUnit.Case, async: true

  alias ExTwitchStory.EventBus

  describe "ok/2" do
    setup do
      handler = fn data -> %ExampleEvent{id: data.id} end
      {:ok, id: UUID.uuid4(), handler: handler}
    end

    test "dispatch {:ok, data} pattern to the handler and the event bus", %{
      id: id,
      handler: handler
    } do
      result = EventBus.ok({:ok, %{id: id}}, handler)

      {:ok, events} = TwitchStory.EventStore.all(id)

      assert result == {:ok, %{id: id}}
      assert events == [%ExampleEvent{id: id}]
    end

    test "does not dispatch {:error, _} pattern to the handler and the event bus", %{
      id: id,
      handler: handler
    } do
      result = EventBus.ok({:error, :reason}, handler)

      {:ok, events} = TwitchStory.EventStore.all(id)

      assert result == {:error, :reason}
      assert events == []
    end
  end

  describe "error/2" do
    setup do
      id = UUID.uuid4()
      handler = fn _reason -> %ExampleEvent{id: id} end
      {:ok, id: id, handler: handler}
    end

    test "dispatch {:error, reason} pattern to the handler and the event bus", %{
      id: id,
      handler: handler
    } do
      result = EventBus.error({:error, :reason}, handler)

      {:ok, events} = TwitchStory.EventStore.all(id)

      assert result == {:error, :reason}
      assert events == [%ExampleEvent{id: id}]
    end

    test "does not dispatch {:ok, data} pattern to the handler and the event bus", %{
      id: id,
      handler: handler
    } do
      result = EventBus.error({:ok, %{id: id}}, handler)

      {:ok, events} = TwitchStory.EventStore.all(id)

      assert result == {:ok, %{id: id}}
      assert events == []
    end
  end
end
