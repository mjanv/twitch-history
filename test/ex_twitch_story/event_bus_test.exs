defmodule ExTwitchStory.EventBusTest do
  use TwitchStory.DataCase

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

      assert result == {:ok, %{id: id}}
      event?(%ExampleEvent{id: id})
    end

    test "does not dispatch {:error, _} pattern to the handler and the event bus", %{
      id: id,
      handler: handler
    } do
      result = EventBus.ok({:error, :reason}, handler)

      assert result == {:error, :reason}
      empty_stream?(%{id: id})
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

      assert result == {:error, :reason}
      event?(%ExampleEvent{id: id})
    end

    test "does not dispatch {:ok, data} pattern to the handler and the event bus", %{
      id: id,
      handler: handler
    } do
      result = EventBus.error({:ok, %{id: id}}, handler)

      assert result == {:ok, %{id: id}}
      empty_stream?(%{id: id})
    end
  end
end
