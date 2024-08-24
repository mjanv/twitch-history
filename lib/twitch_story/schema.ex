defmodule TwitchStory.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, Ecto.UUID, autogenerate: {Uniq.UUID, :uuid7, []}}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]

      import Ecto.Changeset
      import Ecto.Query, warn: false
    end
  end
end
