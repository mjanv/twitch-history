defmodule TwitchStory.Games.Eurovision.Winner do
  @moduledoc false

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :country, :string
    field :points, :integer
  end
end
