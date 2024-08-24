defmodule TwitchStory.Games.Eurovision.Result do
  @moduledoc false

  use TwitchStory.Schema

  @primary_key false
  embedded_schema do
    field :country, :string
    field :points, :integer
    field :votes, :integer
  end
end
