defmodule TwitchStory.Twitch.Channel do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:broadcaster_id, :binary_id, autogenerate: true}

  schema "channels" do
    field :broadcaster_login, :string
    field :broadcaster_name, :string
    field :broadcaster_language, :string
    field :description, :string
    field :tags, {:array, :string}
    field :thumbnail_url, :string
    field :thumbnail, :binary

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [
      :broadcaster_id,
      :broadcaster_login,
      :broadcaster_name,
      :broadcaster_language,
      :description,
      :tags,
      :thumbnail_url,
      :thumbnail
    ])
    |> validate_required([
      :broadcaster_id,
      :broadcaster_login,
      :broadcaster_name,
      :broadcaster_language,
      :description,
      :tags,
      :thumbnail_url,
      :thumbnail
    ])
  end

  import Ecto.Query, warn: false

  alias TwitchStory.Repo

  def list, do: Repo.all(__MODULE__)
  def get!(id), do: Repo.get!(__MODULE__, id)
  def create(attrs \\ %{}), do: Repo.insert(__MODULE__.changeset(%__MODULE__{}, attrs))

  def update(%__MODULE__{} = channel, attrs),
    do: Repo.update(__MODULE__.changeset(channel, attrs))

  def delete(%__MODULE__{} = channel), do: Repo.delete(channel)
  def change(%__MODULE__{} = channel, attrs \\ %{}), do: __MODULE__.changeset(channel, attrs)
end
