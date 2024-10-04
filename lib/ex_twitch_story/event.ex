defmodule TwitchStory.Event do
  @moduledoc """
  Event base struct

  This behaviour defines the base struct for all defined events in the application. It ensures that:

  - The event can be de/serialized to JSON
  - The event has a unique identifier (:id)
  - The event has a timestamp (:at)
  - The event name and timestamp can be humanized (:name)
  """

  alias Timex.Format.Duration.Formatters

  defmacro __using__(opts) do
    keys = [:id, :at] ++ Keyword.get(opts, :keys, [])

    quote do
      alias TwitchStory.Event

      @derive Jason.Encoder
      defstruct unquote(keys)
    end
  end

  @doc "Returns the humanized representation of an event name/timestamp"
  @spec humanize(map(), :name | :at) :: String.t()
  def humanize(%{__struct__: struct}, :name) do
    struct
    |> Module.split()
    |> Enum.join(".")
  end

  def humanize(%{at: at}, :at) do
    Timex.now()
    |> Timex.diff(at, :duration)
    |> Formatters.Humanized.format()
  end
end

defprotocol EventImpl do
  @fallback_to_any true
  def humanize(event, key)
end

defimpl EventImpl, for: Any do
  def humanize(event, key), do: TwitchStory.Event.humanize(event, key)
end
