defmodule ExTwitchStory.EventBusTest do
  use ExUnit.Case, async: true

  alias ExTwitchStory.EventBus

  defmodule ExampleEvent do
    use TwitchStory.Event,
      keys: [:key]
  end

  test "Event can be dispatched in a pipeline" do
    id = UUID.uuid4()

    result_ok = EventBus.ok({:ok, %{id: id}}, fn user -> %ExampleEvent{id: user.id} end)
    result_error = EventBus.error({:error, :reason}, fn _reason -> %ExampleEvent{id: id} end)

    assert result_ok == {:ok, %{id: id}}
    assert result_error == {:error, :reason}
  end
end
