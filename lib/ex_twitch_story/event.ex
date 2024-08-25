defmodule TwitchStory.Event do
  @moduledoc false

  alias Timex.Format.Duration.Formatters

  defmacro __using__(opts) do
    keys = [:id, :at] ++ Keyword.get(opts, :keys, [])

    quote do
      alias TwitchStory.Event

      @derive Jason.Encoder
      defstruct unquote(keys)
    end
  end

  def humanize(%{__struct__: struct}, :name) do
    Atom.to_string(struct)
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
