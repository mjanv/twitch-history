defmodule TwitchStory.Twitch.Channels.Channel do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  schema "channels" do
    field :broadcaster_id, :string
    field :broadcaster_login, :string
    field :broadcaster_name, :string
    field :broadcaster_language, :string
    field :description, :string
    field :tags, {:array, :string}
    field :thumbnail_url, :string
    field :thumbnail, :binary

    many_to_many :users, TwitchStory.Accounts.User,
      join_through: TwitchStory.Accounts.FollowedChannel

    timestamps(type: :utc_datetime)
  end

  @casts [
    :broadcaster_id,
    :broadcaster_login,
    :broadcaster_name,
    :broadcaster_language,
    :description,
    :tags,
    :thumbnail_url,
    :thumbnail
  ]

  @validations [
    :broadcaster_id,
    :broadcaster_login,
    :broadcaster_name
  ]

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, @casts)
    |> validate_required(@validations)
  end

  def change(%__MODULE__{} = channel, attrs \\ %{}), do: __MODULE__.changeset(channel, attrs)

  def all, do: Repo.all(__MODULE__)

  def page(page, page_size \\ 10, order_by \\ [asc: :broadcaster_id]) do
    __MODULE__
    |> order_by(^order_by)
    |> Repo.paginate(page: page, page_size: page_size)
    |> Map.get(:entries)
  end

  def count, do: Repo.count(__MODULE__)

  def get!(id), do: Repo.get_by(__MODULE__, broadcaster_id: id)
  def create(attrs \\ %{}), do: Repo.insert(__MODULE__.changeset(%__MODULE__{}, attrs))

  def update(%__MODULE__{} = channel, attrs),
    do: Repo.update(__MODULE__.changeset(channel, attrs))

  def delete(%__MODULE__{} = channel), do: Repo.delete(channel)
end
