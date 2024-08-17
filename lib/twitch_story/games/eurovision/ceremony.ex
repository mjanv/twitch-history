defmodule TwitchStory.Games.Eurovision.Ceremony do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Vote
  alias TwitchStory.Games.Eurovision.Winner
  alias TwitchStory.Repo

  schema "eurovision_ceremonies" do
    field :name, :string
    field :status, Ecto.Enum, values: [:started, :completed, :cancelled]
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

  def get(id), do: Repo.get!(__MODULE__, id)

  def all(user_id: id) do
    from(c in __MODULE__,
      where: c.user_id == ^id
    )
    |> Repo.all()
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def complete(%__MODULE__{id: id} = ceremony) do
    ceremony
    |> changeset(%{status: :completed, winner: Vote.winner(id)})
    |> Repo.update()
  end

  def cancel(%__MODULE__{} = ceremony) do
    ceremony
    |> changeset(%{status: :cancelled})
    |> Repo.update()
  end

  def add_vote(%__MODULE__{id: id}, attrs) do
    attrs
    |> Map.put(:ceremony_id, id)
    |> Vote.create()
  end

  def add_votes(%__MODULE__{id: id}, attrs) do
    attrs
    |> Enum.map(fn vote -> Map.put(vote, :ceremony_id, id) end)
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {vote, i}, multi ->
      Ecto.Multi.insert(multi, i, Vote.changeset(%Vote{}, vote))
    end)
    |> Repo.transaction()
    |> case do
      {:ok, results} -> {:ok, Map.values(results)}
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
    %{votes: Vote.total_votes(id), points: Vote.total_points(id)}
  end

  def user_votes(%__MODULE__{id: id}, %{id: user_id}) do
    Vote.user_votes(id, user_id)
  end

  def results(%__MODULE__{id: id}), do: Vote.results(id)

  def winner(%__MODULE__{status: :completed, winner: winner}), do: winner.country
  def winner(%__MODULE__{}), do: nil
end
