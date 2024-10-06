defmodule TwitchStory.Twitch.FollowedChannel do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.Channels.Channel

  @type t() :: %__MODULE__{
          user_id: String.t(),
          channel_id: String.t(),
          followed_at: NaiveDateTime.t()
        }

  @primary_key false
  @derive {Jason.Encoder, only: [:channel, :followed_at]}
  schema "followed_channels" do
    belongs_to :user, User
    belongs_to :channel, Channel

    field :followed_at, :utc_datetime
  end

  def changeset(followed_channel, attrs \\ %{}) do
    followed_channel
    |> cast(attrs, [:user_id, :channel_id, :followed_at])
    |> validate_required([:user_id, :channel_id, :followed_at])
  end

  @doc """
  - Get all followed channels by a specific user
  - Get all users following a specific channel
  """
  @spec all(Keyword.t()) :: [t()]
  def all(attrs) do
    __MODULE__
    |> where(^attrs)
    |> order_by(desc: :followed_at)
    |> Repo.all()
    |> Repo.preload([:channel, :user])
  end

  @doc "Get count of followed channels by year for a specific user"
  def count_by_year(user_id) do
    from(fc in __MODULE__,
      where: fc.user_id == ^user_id,
      group_by: fragment("date_trunc('year', ?)", fc.followed_at),
      select: {fragment("date_trunc('year', ?)", fc.followed_at), count(fc.user_id)},
      order_by: [desc: fragment("date_trunc('year', ?)", fc.followed_at)]
    )
    |> Repo.all()
    |> Enum.map(fn {datetime, count} -> {datetime.year, count} end)
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
