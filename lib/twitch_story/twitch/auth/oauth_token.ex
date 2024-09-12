defmodule TwitchStory.Twitch.Auth.OauthToken do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  schema "twitch_oauth_tokens" do
    field :access_token, :binary
    field :refresh_token, :binary
    field :scopes, {:array, :string}
    field :expires_at, :utc_datetime

    belongs_to :user, TwitchStory.Accounts.User

    timestamps()
  end

  def count do
    Repo.one(from t in __MODULE__, select: count(t.id))
  end

  def all do
    Repo.all(__MODULE__) |> Repo.preload(:user)
  end

  def get(%{id: user_id}) do
    __MODULE__
    |> Repo.get_by(user_id: user_id)
    |> case do
      nil -> {:error, nil}
      token -> {:ok, token}
    end
  end

  def expiring?(n) do
    from(
      t in __MODULE__,
      where: t.expires_at <= ^DateTime.add(DateTime.utc_now(), n, :second)
    )
    |> Repo.all()
  end

  def create(attrs, %{id: user_id}) do
    %__MODULE__{}
    |> changeset(Map.put(attrs, :user_id, user_id))
    |> Repo.insert()
  end

  def update(attrs, %{id: user_id}) do
    __MODULE__
    |> Repo.get_by(user_id: user_id)
    |> changeset(Map.put(attrs, :user_id, user_id))
    |> Repo.update()
  end

  defp changeset(oauth_token, attrs) do
    oauth_token
    |> cast(attrs, [:access_token, :refresh_token, :scopes, :expires_at, :user_id])
    |> validate_required([:access_token, :refresh_token, :scopes, :expires_at, :user_id])
  end
end
