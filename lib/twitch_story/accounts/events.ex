defmodule UserCreated do
  @moduledoc false

  use TwitchStory.Event

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "User created"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule UserDeleted do
  @moduledoc false

  use TwitchStory.Event

  defimpl EventImpl, for: __MODULE__ do
    def humanize(_, :name), do: "User deleted"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end

defmodule RoleAssigned do
  @moduledoc false

  use TwitchStory.Event,
    keys: [:role]

  defimpl EventImpl, for: __MODULE__ do
    def humanize(%{role: role}, :name), do: "#{String.capitalize(role)} role assigned"
    def humanize(event, key), do: Event.humanize(event, key)
  end
end
