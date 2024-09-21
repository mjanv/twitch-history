defmodule Eurovision.CeremonyCreated do
  @moduledoc false

  use TwitchStory.Event,
    keys: [:user_id]

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game created"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule Eurovision.CeremonyStatusChanged do
  @moduledoc false

  use TwitchStory.Event,
    keys: [:status]

  defimpl EventImpl, for: __MODULE__ do
    def humanize(event, :name), do: "Eurovision game #{event.status}"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule Eurovision.CeremonyDeleted do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game deleted"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end
