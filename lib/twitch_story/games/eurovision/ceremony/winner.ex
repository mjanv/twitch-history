defmodule TwitchStory.Games.Eurovision.Ceremony.Winner do
  @moduledoc false

  use TwitchStory.Schema

  @type t() :: %__MODULE__{
          country: String.t(),
          points: integer()
        }

  @primary_key false
  embedded_schema do
    field :country, :string
    field :points, :integer
  end

  def changeset(%__MODULE__{} = winner, attrs) do
    winner
    |> cast(attrs, [:country, :points])
    |> validate_required([:country, :points])
  end
end
