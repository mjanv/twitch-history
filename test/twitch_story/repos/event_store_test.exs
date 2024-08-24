defmodule TwitchStory.Repos.EventStoreTest do
  use TwitchStory.DataCase, async: true

  alias TwitchStory.EventStore

  defmodule ExampleEvent do
    @derive Jason.Encoder
    defstruct [:id, :key]
  end

  test "Event can be dispatched to a stream to the event store" do
    id = UUID.uuid4()
    event = %ExampleEvent{id: id, key: "a"}

    {:ok, uuid} = EventStore.dispatch(event)

    {:ok, events} = EventStore.all(event.id)

    assert uuid == event.id
    assert events == [%ExampleEvent{id: id, key: "a"}]
  end

  test "Event(s) can be dispatched in a pipeline" do
    id = UUID.uuid4()

    dispatcher = fn
      {:ok, [_ | _] = users} -> Enum.map(users, fn user -> %ExampleEvent{id: user.id} end)
      {:ok, user} -> %ExampleEvent{id: user.id}
      _ -> nil
    end

    result_ok_value = EventStore.tap({:ok, %{id: id}}, dispatcher)
    result_ok_list = EventStore.tap({:ok, [%{id: id}, %{id: id}]}, dispatcher)
    result_error = EventStore.tap({:error, :reason}, dispatcher)

    assert result_ok_value == {:ok, %{id: id}}
    assert result_ok_list == {:ok, [%{id: id}, %{id: id}]}
    assert result_error == {:error, :reason}
  end

  test "Events can be dispatched to streams to the event store" do
    id1 = UUID.uuid4()
    id2 = UUID.uuid4()

    events1 = [
      %ExampleEvent{id: id1, key: "a"},
      %ExampleEvent{id: id1, key: "b"},
      %ExampleEvent{id: id1, key: "c"}
    ]

    events2 = [
      %ExampleEvent{id: id2, key: "d"},
      %ExampleEvent{id: id2, key: "e"}
    ]

    {:ok, uuid1} = EventStore.dispatch(events1)
    {:ok, uuid2} = EventStore.dispatch(events2)

    {:ok, events1} = EventStore.all(id1)
    {:ok, events2} = EventStore.all(id2)

    assert uuid1 == id1
    assert uuid2 == id2

    assert events1 == [
             %ExampleEvent{id: id1, key: "a"},
             %ExampleEvent{id: id1, key: "b"},
             %ExampleEvent{id: id1, key: "c"}
           ]

    assert events2 == [
             %ExampleEvent{id: id2, key: "d"},
             %ExampleEvent{id: id2, key: "e"}
           ]
  end
end
