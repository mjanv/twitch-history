defmodule TwitchStory.Games.Eurovision.Ceremony do
  @moduledoc false

  use TwitchStory.Schema

  alias ExTwitchStory.EventBus
  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Ceremony.Result
  alias TwitchStory.Games.Eurovision.Ceremony.Vote
  alias TwitchStory.Games.Eurovision.Ceremony.Winner

  @type t() :: %__MODULE__{
          name: String.t(),
          status: atom(),
          countries: [String.t()],
          votes: [Vote.t()],
          voters: [User.t()],
          user_id: String.t(),
          winner: Winner.t() | nil,
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "eurovision_ceremonies" do
    field :name, :string
    field :status, Ecto.Enum, values: [:created, :started, :paused, :completed, :cancelled]
    field :countries, {:array, :string}

    belongs_to :user, User
    has_many :votes, Vote
    has_many :voters, through: [:votes, :user]

    embeds_one :winner, Winner

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = ceremony, attrs) do
    ceremony
    |> cast(attrs, [:name, :status, :countries, :user_id])
    |> validate_required([:name, :status, :countries, :user_id])
    |> assoc_constraint(:user)
    |> cast_embed(:winner, required: false)
  end

  def form(attrs \\ %{}), do: changeset(%__MODULE__{}, attrs)

  def get(id) do
    __MODULE__
    |> Repo.get(id)
    |> Repo.preload([:user])
  end

  def all(user_id: id) do
    from(c in __MODULE__,
      where: c.user_id == ^id
    )
    |> preload(:user)
    |> Repo.all()
  end

  @doc "Get all active ceremonies"
  @spec actives :: [t()]
  def actives do
    from(c in __MODULE__, where: c.status == :started)
    |> preload(:user)
    |> Repo.all()
  end

  @doc "Get all past ceremonies"
  @spec pasts :: [t()]
  def pasts do
    from(c in __MODULE__, where: c.status in [:completed, :cancelled])
    |> preload(:user)
    |> Repo.all()
  end

  @doc "Create a new ceremony"
  @spec create(map()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(Map.merge(attrs, %{status: :created}))
    |> Repo.insert()
    |> EventBus.ok(fn ceremony -> %EurovisionCeremonyCreated{id: ceremony.id} end)
  end

  @doc "Delete a ceremony"
  @spec delete(t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete(%__MODULE__{} = ceremony) do
    ceremony
    |> Repo.delete()
    |> EventBus.ok(fn ceremony -> %EurovisionCeremonyDeleted{id: ceremony.id} end)
  end

  # STATE MACHINE API
  # -----------------

  @doc "Start a ceremony"
  def start(%__MODULE__{status: status} = ceremony) when status in [:created, :paused] do
    ceremony
    |> changeset(%{status: :started})
    |> Repo.update()
    |> EventBus.ok(fn ceremony -> %EurovisionCeremonyStarted{id: ceremony.id} end)
  end

  def start(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  @doc "Pause a ceremony"
  def pause(%__MODULE__{status: status} = ceremony) when status in [:created, :started] do
    ceremony
    |> changeset(%{status: :paused})
    |> Repo.update()
    |> EventBus.ok(fn ceremony -> %EurovisionCeremonyPaused{id: ceremony.id} end)
  end

  def pause(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  @doc "Complete a ceremony"
  def complete(%__MODULE__{id: id, status: status} = ceremony)
      when status in [:created, :started, :paused] do
    ceremony
    |> changeset(%{
      status: :completed,
      winner:
        case Vote.winner(id) do
          nil -> nil
          winner -> Map.from_struct(winner)
        end
    })
    |> Repo.update()
    |> EventBus.ok(fn ceremony -> %EurovisionCeremonyCompleted{id: ceremony.id} end)
  end

  def complete(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  @doc "Cancel a ceremony"
  def cancel(%__MODULE__{status: status} = ceremony)
      when status in [:created, :started, :paused] do
    ceremony
    |> changeset(%{status: :cancelled})
    |> Repo.update()
    |> EventBus.ok(fn ceremony -> %EurovisionCeremonyCancelled{id: ceremony.id} end)
  end

  def cancel(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  # VOTE API
  # --------

  @doc "Get all votes of a ceremony"
  @spec votes(t()) :: [Vote.t()]
  def votes(%__MODULE__{id: id}), do: Vote.all(id)

  @doc "Get the votes of an user"
  @spec user_votes(t(), User.t()) :: [Vote.t()]
  def user_votes(%__MODULE__{id: id}, %{id: user_id}), do: Vote.user_votes(id, user_id)

  @doc "Add a vote"
  @spec add_vote(t(), map()) :: {:ok, Vote.t()} | {:error, Ecto.Changeset.t()}
  def add_vote(%__MODULE__{id: id}, attrs) do
    attrs
    |> Map.put(:ceremony_id, id)
    |> Vote.create()
  end

  @doc "Add votes"
  @spec add_votes(t(), [map()]) :: {:ok, [Vote.t()]} | {:error, Ecto.Changeset.t()}
  def add_votes(%__MODULE__{id: id}, attrs) do
    attrs
    |> Enum.map(fn vote -> Map.put(vote, :ceremony_id, id) end)
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {vote, i}, multi ->
      Ecto.Multi.insert_or_update(
        multi,
        i,
        Vote.changeset(
          Vote.get_by(
            ceremony_id: vote.ceremony_id,
            user_id: vote.user_id,
            country: vote.country
          ),
          vote
        )
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, votes} -> {:ok, Map.values(votes)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Delete a vote"
  @spec delete_vote(t(), Vote.t()) :: {:ok, Vote.t()} | {:error, atom() | Ecto.Changeset.t()}
  def delete_vote(%__MODULE__{}, vote), do: Vote.delete(vote)

  @doc "Get all voters of a ceremony"
  @spec voters(t()) :: [User.t()]
  def voters(%__MODULE__{} = ceremony) do
    __MODULE__
    |> Repo.get!(ceremony.id)
    |> Repo.preload(:voters)
    |> Map.get(:voters)
  end

  # RESULTS API
  # -----------

  @spec totals(t()) :: %{votes: integer(), voters: integer(), points: integer()}
  def totals(%__MODULE__{id: id}) do
    %{
      votes: Vote.total(id, :count),
      voters: Vote.total(id, :distinct, :user_id),
      points: Vote.total(id, :sum, :points)
    }
  end

  @doc "Get the leaderboard of a ceremony"
  @spec leaderboard(t()) :: [Result.t()]
  def leaderboard(%__MODULE__{id: id}), do: Vote.leaderboard(id)

  @doc "Get the winner of a ceremony"
  @spec winner(t()) :: String.t() | nil
  def winner(%__MODULE__{status: :completed, winner: %Winner{country: country}}), do: country
  def winner(%__MODULE__{}), do: nil
end
