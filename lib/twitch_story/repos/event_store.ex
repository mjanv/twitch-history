defmodule TwitchStory.EventStore do
  @moduledoc false

  use EventStore, otp_app: :twitch_story

  alias EventStore.EventData

  require Logger

  def init(config) do
    {:ok, config}
  end

  def ok(value, build) do
    __MODULE__.tap(value, fn
      {:ok, user} -> build.(user)
      {:error, _} -> nil
    end)
  end

  def error(value, build) do
    __MODULE__.tap(value, fn
      {:ok, _} -> nil
      {:error, reason} -> build.(reason)
    end)
  end

  def tap(value, dispatcher) do
    value
    |> dispatcher.()
    |> case do
      nil -> :ok
      events when is_list(events) -> dispatch(events)
      event -> dispatch(event)
    end

    value
  end

  def dispatch(event_or_events, key \\ :id)

  def dispatch(events, key) when is_list(events) do
    events
    |> Enum.map(fn event -> dispatch(event, key) end)
    |> Enum.reduce_while({:ok, UUID.uuid4()}, fn
      {:ok, uuid}, _ -> {:cont, {:ok, uuid}}
      {:error, reason}, _ -> {:halt, {:error, reason}}
    end)
  end

  def dispatch(event, key) when is_map(event) do
    with uuid <- Map.get(event, key, UUID.uuid4()),
         event <- %EventData{
           event_type: Atom.to_string(event.__struct__),
           data: event,
           metadata: %{}
         },
         :ok <- append_to_stream(uuid, :any_version, [event]) do
      {:ok, uuid}
    else
      reason ->
        Logger.error("Cannot dispatch event due to: #{inspect(reason)}")
        {:error, :cannot_dispatch}
    end
  end

  def all(stream_uuid) do
    stream_uuid
    |> read_stream_forward()
    |> case do
      {:ok, events} -> {:ok, Enum.map(events, fn %{data: data} -> data end)}
    end
  end
end
