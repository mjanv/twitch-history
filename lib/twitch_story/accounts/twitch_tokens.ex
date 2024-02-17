defmodule TwitchStory.Accounts.TwitchTokens do
  @moduledoc false

  use Ecto.Schema

  schema "users_tokens" do
    field :token, :binary
    field :access_token, :binary
    field :refresh_token, :binary
    field :scope, {:array, :string}

    belongs_to :user, TwitchStory.Accounts.User

    timestamps(updated_at: false)
  end
end
