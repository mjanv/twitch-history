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

  @doc """
  - Get all followed channels by a specific user
  - Get all users following a specific channel
  """
  def all(user_id: user_id) do
    from(
      c in __MODULE__,
      where: c.user_id == ^user_id,
      order_by: [desc: :followed_at]
    )
    |> Repo.all()
    |> Repo.preload(:channel)
  end

  def all(channel_id: channel_id) do
    from(c in __MODULE__, where: c.channel_id == ^channel_id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc "Register followed channels"
  def follow_channels(user, channels) do
    channels = channels |> Enum.map(fn c -> {c.broadcaster_id, c} end) |> Enum.into(%{})

    Channel
    |> where([channel], channel.broadcaster_id in ^Map.keys(channels))
    |> Repo.all()
    |> Enum.map(fn c ->
      %{
        channel_id: c.id,
        user_id: user.id,
        followed_at: channels[c.broadcaster_id].followed_at
      }
    end)
    |> then(fn channels ->
      Repo.insert_all(__MODULE__, channels,
        on_conflict: {:replace, [:followed_at]},
        conflict_target: [:user_id, :channel_id]
      )

      :ok
    end)
  end
end
