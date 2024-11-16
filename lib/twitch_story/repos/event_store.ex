defmodule TwitchStory.EventStore do
  @moduledoc """
  Event Store

  The event store is used to store events in a PostgreSQL backend. Any event can be dispatched to the event store using the `dispatch/1` function. An event is any struct that implements the `use TwitchStory.Event` behaviour.

  Each event is dispatched on a stream with a specific UUID corresponding to the id of the event. A stream is the sequence that describes the lifetime of a specific ressource (user, channel, request, etc.). All events of a given stream or from all streams can be retrieved.

  ## Example

    defmodule UserCreated do
      use TwitchStory.Event,
        keys: [:id]
    end

    iex> TwitchStory.EventStore.dispatch(%UserCreated{id: UUID.uuid4()})

      {:ok, 'e1a1e3f0-e0a0-4e0e-a4e4-0e4e40e4e40e'}

    iex> TwitchStory.EventStore.all('e1a1e3f0-e0a0-4e0e-a4e4-0e4e40e4e40e')

      {:ok, [%UserCreated{id: 'e1a1e3f0-e0a0-4e0e-a4e4-0e4e40e4e40e'}]}

  """

  use EventStore, otp_app: :twitch_story

  @behaviour TwitchStory.EventBus.Dispatcher

  alias EventStore.EventData

  def init(config) do
    {:ok, config}
  end

  @doc "Dispatch an event to the event store"
  @spec dispatch(map()) :: {:ok, String.t()} | {:error, atom()}
  def dispatch(event) when is_map(event) do
    with uuid <- Map.get(event, :id, UUID.uuid4()),
         event <- %EventData{
           event_type: Atom.to_string(event.__struct__),
           data: event,
           metadata: %{}
         },
         :ok <- append_to_stream(uuid, :any_version, [event]) do
      {:ok, uuid}
    else
      _ -> {:error, :cannot_dispatch}
    end
  end

  @doc "Returns the last N events of all streams"
  @spec last(integer()) :: {:ok, [any()]}
  def last(n \\ 100) do
    -1
    |> read_all_streams_backward(n)
    |> case do
      {:ok, events} -> events
      {:error, _reason} -> []
    end
    |> Enum.map(fn %{data: data, created_at: at} -> Map.put(data, :at, at) end)
    |> then(fn events -> {:ok, events} end)
  end

  @doc """
  Returns all events of a stream

  If `with_timestamps` is true, the events will be returned with the timestamps.
  """
  @spec all(String.t(), boolean()) :: {:ok, [any()]}
  def all(stream_uuid, with_timestamps \\ false) do
    stream_uuid
    |> read_stream_forward()
    |> case do
      {:ok, events} -> events
      {:error, :stream_not_found} -> []
    end
    |> then(fn events ->
      if with_timestamps do
        Enum.map(events, fn %{data: data, created_at: at} -> Map.put(data, :at, at) end)
      else
        Enum.map(events, fn %{data: data} -> data end)
      end
    end)
    |> then(fn events -> {:ok, events} end)
  end
end
