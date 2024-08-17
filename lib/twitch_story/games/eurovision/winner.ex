defmodule TwitchStory.Games.Eurovision.Winner do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

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
