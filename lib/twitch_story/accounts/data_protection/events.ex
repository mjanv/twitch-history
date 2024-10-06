defmodule DataExportRequested do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Data export requested"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule DataExportGenerated do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Data export generated"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule DataExportTransmitted do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Data export transmitted"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end
