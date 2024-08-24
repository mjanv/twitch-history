defmodule TwitchStory.Twitch.Auth.OauthToken do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Accounts.User
  alias TwitchStory.Repo

  schema "twitch_oauth_tokens" do
    field :access_token, :binary
    field :refresh_token, :binary
    field :scopes, {:array, :string}

    belongs_to :user, TwitchStory.Accounts.User

    timestamps(updated_at: false)
  end

  def create(token, %User{} = user) do
    user
    |> Ecto.build_assoc(:twitch_token, token)
    |> Repo.insert()
  end

  def update(token, %User{} = user) do
    user = user |> Repo.preload(:twitch_token)

    user.twitch_token
    |> change(token)
    |> Repo.update()
  end

  def get(%User{} = user) do
    user
    |> Repo.preload(:twitch_token)
    |> Map.get(:twitch_token)
  end

  def count do
    Repo.one(from t in __MODULE__, select: count(t.id))
  end
end
