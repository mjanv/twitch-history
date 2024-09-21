defmodule TwitchStory.Repos.EventStoreTest do
  use TwitchStory.DataCase, async: true

  alias TwitchStory.EventStore

  test "Event can be dispatched to a stream to the event store" do
    id = UUID.uuid4()
    event = %ExampleEvent{id: id, key: "a"}

    {:ok, uuid} = EventStore.dispatch(event)

    {:ok, events} = EventStore.all(event.id)

    assert uuid == event.id
    assert events == [%ExampleEvent{id: id, key: "a"}]
  end
end
