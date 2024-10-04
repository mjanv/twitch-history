defmodule SynchronizationPlanned do
  @moduledoc false

  use TwitchStory.Event,
    keys: [:name, :n]

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Synchronization planned"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule SynchronizationFinished do
  @moduledoc false

  use TwitchStory.Event,
    keys: [:name]

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Synchronization finished"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end
