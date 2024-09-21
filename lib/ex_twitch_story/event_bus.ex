defmodule ExTwitchStory.EventBus do
  @moduledoc """
  Event bus

  The event bus is used to dispatch events to all registered dispatchers. A dispatcher is any module that implements the `use ExTwitchStory.EventBus.Dispatcher` behaviour. The list of dispatchers is defined in the `config/` folder.
  """

  defmodule Dispatcher do
    @moduledoc false

    @callback dispatch(any()) :: any()
  end

  @behaviour __MODULE__.Dispatcher

  @dispatchers Application.compile_env(:twitch_story, :event_bus)

  @type data() :: {:ok, any()} | {:error, any()}

  @doc """
  Dispatch {:ok, _} pattern to the event bus

  The data can be preprocessed by the handler before being dispatched to the event bus.

  ## Example

      iex> EventBus.ok({:ok, %{id: "id"}}, fn data -> %ExampleEvent{id: data.id} end)
      {:ok, %{id: "id}}
  """
  @spec ok(data(), (any() -> any())) :: data()
  def ok({:ok, result} = value, build) do
    :ok = dispatch(build.(result))
    value
  end

  def ok(value, _), do: value

  @doc """
  Dispatch {:error, _} pattern to the event bus

  The data can be preprocessed by the handler before being dispatched to the event bus.

  ## Example

      iex> EventBus.error({:error, :reason}, fn _reason -> %ExampleEvent{id: "id"} end)
      {:error, :reason}
  """
  @spec error(data(), (any() -> any())) :: data()
  def error({:error, reason} = value, build) do
    :ok = dispatch(build.(reason))
    value
  end

  def error(value, _), do: value

  @doc """
  Dispatch an event to all registered dispatchers

  Event is dispatched in a synchronous manner. Dispatcher need to end execution before the next dispatcher is called. A failure in one dispatcher will block the execution of all next dispatchers.
  """
  @spec dispatch(any()) :: :ok
  def dispatch(event) do
    for dispatcher <- @dispatchers do
      dispatcher.dispatch(event)
    end

    :ok
  end
end

defmodule ExampleEvent do
  @moduledoc false

  use TwitchStory.Event, keys: [:key]
end
