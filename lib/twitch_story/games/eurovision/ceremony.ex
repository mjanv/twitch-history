defmodule TwitchStory.Games.Eurovision.Ceremony do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Vote
  alias TwitchStory.Games.Eurovision.Winner
  alias TwitchStory.Repo

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

  def actives do
    from(c in __MODULE__, where: c.status == :started)
    |> preload(:user)
    |> Repo.all()
  end

  def pasts do
    from(c in __MODULE__, where: c.status in [:completed, :cancelled])
    |> preload(:user)
    |> Repo.all()
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(Map.merge(attrs, %{status: :created}))
    |> Repo.insert()
  end

  def start(%__MODULE__{status: status} = ceremony) when status in [:created, :paused] do
    ceremony
    |> changeset(%{status: :started})
    |> Repo.update()
  end

  def start(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  def pause(%__MODULE__{status: status} = ceremony) when status in [:created, :started] do
    ceremony
    |> changeset(%{status: :paused})
    |> Repo.update()
  end

  def pause(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  def complete(%__MODULE__{id: id, status: status} = ceremony)
      when status in [:created, :started, :paused] do
    ceremony
    |> changeset(%{status: :completed, winner: Vote.winner(id)})
    |> Repo.update()
  end

  def complete(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  def cancel(%__MODULE__{status: status} = ceremony)
      when status in [:created, :started, :paused] do
    ceremony
    |> changeset(%{status: :cancelled})
    |> Repo.update()
  end

  def cancel(%__MODULE__{status: status}), do: {:error, :"already_#{status}"}

  def delete(%__MODULE__{} = ceremony) do
    ceremony
    |> Repo.delete()
  end

  def add_vote(%__MODULE__{id: id}, attrs) do
    attrs
    |> Map.put(:ceremony_id, id)
    |> Vote.create()
  end

  def init_votes(%__MODULE__{countries: countries} = ceremony, voter) do
    countries
    |> Enum.map(fn country -> %{country: country, points: 0, user_id: voter.id} end)
    |> then(fn votes -> add_votes(ceremony, votes) end)
  end

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

  def delete_vote(%__MODULE__{}, vote), do: Vote.delete(vote)

  def votes(%__MODULE__{id: id}), do: Vote.all(id)

  def voters(%__MODULE__{} = ceremony) do
    __MODULE__
    |> Repo.get!(ceremony.id)
    |> Repo.preload(:voters)
    |> Map.get(:voters)
  end

  def totals(%__MODULE__{id: id}) do
    %{votes: Vote.total_votes(id), voters: Vote.total_voters(id), points: Vote.total_points(id)}
  end

  def user_votes(%__MODULE__{id: id}, %{id: user_id}) do
    Vote.user_votes(id, user_id)
  end

  def leaderboard(%__MODULE__{id: id}), do: Vote.leaderboard(id)

  def winner(%__MODULE__{status: :completed, winner: nil}), do: nil
  def winner(%__MODULE__{status: :completed, winner: winner}), do: winner.country
  def winner(%__MODULE__{}), do: nil
end
