defmodule TwitchStory.Accounts.FollowedChannel do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.Channels.Channel

  @primary_key false
  schema "followed_channels" do
    belongs_to :user, User
    belongs_to :channel, Channel

    field :followed_at, :utc_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:user_id, :channel_id, :followed_at])
    |> Ecto.Changeset.validate_required([:user_id, :channel_id, :followed_at])
  end

  @doc "Get all followed channels by a specific user"
  def all(user_id) do
    from(c in __MODULE__, where: c.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(:channel)
  end

  @doc "Register followed channels"
  def follow_channels(user, channels) do
    channels
    |> Enum.map(fn %{broadcaster_id: broadcaster_id, followed_at: followed_at} ->
      channel = Channel.get!(broadcaster_id)
      attrs = %{user_id: user.id, channel_id: channel.id, followed_at: followed_at}
      changeset(%__MODULE__{}, attrs)
    end)
    |> Enum.reduce(Ecto.Multi.new(), fn changeset, multi ->
      Ecto.Multi.insert(multi, UUID.uuid4(), changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> {:ok, all(user.id)}
      {:error, reason} -> {:error, reason}
    end
  end
end
