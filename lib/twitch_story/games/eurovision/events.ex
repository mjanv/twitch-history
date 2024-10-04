defmodule EurovisionCeremonyCreated do
  @moduledoc false

  use TwitchStory.Event,
    keys: [:user_id]

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game created"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule EurovisionCeremonyStarted do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game started"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule EurovisionCeremonyPaused do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game paused"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule EurovisionCeremonyCompleted do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game completed"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule EurovisionCeremonyCancelled do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game cancelled"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule EurovisionCeremonyDeleted do
  @moduledoc false

  use TwitchStory.Event,
    keys: []

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "Eurovision game deleted"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end
