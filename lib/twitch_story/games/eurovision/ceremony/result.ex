defmodule TwitchStory.Games.Eurovision.Ceremony.Result do
  @moduledoc false

  use TwitchStory.Schema

  @type t() :: %__MODULE__{
          country: String.t(),
          points: integer(),
          votes: integer()
        }

  @primary_key false
  embedded_schema do
    field :country, :string
    field :points, :integer
    field :votes, :integer
  end
end
