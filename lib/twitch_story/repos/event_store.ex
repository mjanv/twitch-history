defmodule TwitchStory.EventStore do
  @moduledoc false

  use EventStore, otp_app: :twitch_story

  alias EventStore.EventData

  def init(config) do
    {:ok, config}
  end

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
