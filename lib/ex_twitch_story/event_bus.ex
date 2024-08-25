defmodule ExTwitchStory.EventBus do
  @moduledoc false

  defmodule Dispatcher do
    @moduledoc false

    @callback dispatch(any()) :: any()
  end

  @behaviour __MODULE__.Dispatcher

  @dispatchers Application.compile_env(:twitch_story, :event_bus)

  def ok({:ok, result} = value, build) do
    dispatch(build.(result))
    value
  end

  def ok(value, _), do: value

  def error({:error, reason} = value, build) do
    dispatch(build.(reason))
    value
  end

  def error(value, _), do: value

  def dispatch(event) do
    for dispatcher <- @dispatchers do
      dispatcher.dispatch(event)
    end
  end
end
