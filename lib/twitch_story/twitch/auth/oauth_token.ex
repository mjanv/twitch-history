defmodule TwitchStory.Twitch.Auth.OauthToken do
  @moduledoc false

  use TwitchStory.Schema

  schema "twitch_oauth_tokens" do
    field :access_token, :binary
    field :refresh_token, :binary
    field :scopes, {:array, :string}
    field :expires_at, :utc_datetime

    belongs_to :user, TwitchStory.Accounts.User

    timestamps()
  end

  def count, do: Repo.count(__MODULE__)

  def all do
    __MODULE__
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def get(%{id: user_id}) do
    __MODULE__
    |> Repo.get_by(user_id: user_id)
    |> Repo.preload(:user)
    |> case do
      nil -> {:error, nil}
      token -> {:ok, token}
    end
  end

  def expired?(%__MODULE__{expires_at: expires_at}) do
    DateTime.compare(expires_at, DateTime.utc_now()) == :lt
  end

  def expired?(_), do: true

  def expiring?(n) when is_integer(n) do
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

  def create_or_update(attrs, user) do
    case get(user) do
      {:ok, _} -> __MODULE__.update(attrs, user)
      {:error, _} -> __MODULE__.create(attrs, user)
    end
  end

  defp changeset(oauth_token, attrs) do
    oauth_token
    |> cast(attrs, [:access_token, :refresh_token, :scopes, :expires_at, :user_id])
    |> validate_required([:access_token, :refresh_token, :scopes, :expires_at, :user_id])
  end
end
