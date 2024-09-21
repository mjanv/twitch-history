defmodule TwitchStory.Games.Eurovision.Ceremony.Vote do
  @moduledoc """
  A vote is a user's vote for a country in a ceremony.

  Vote is represented by a country code and a number of points.
  """

  use TwitchStory.Schema

  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Ceremony
  alias TwitchStory.Repo

  @type vote() :: %{
          required(:ceremony_id) => String.t(),
          required(:user_id) => String.t(),
          required(:country) => String.t()
        }

  @type t() :: %__MODULE__{
          country: String.t(),
          points: integer(),
          ceremony_id: String.t(),
          user_id: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "eurovision_votes" do
    field :country, :string
    field :points, :integer

    belongs_to :ceremony, Ceremony
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:country, :points, :ceremony_id, :user_id])
    |> validate_required([:country, :points, :ceremony_id, :user_id])
    |> validate_number(:points, greater_than_or_equal_to: 0, less_than_or_equal_to: 12)
    |> validate_country_in_ceremony()
    |> assoc_constraint(:ceremony)
    |> assoc_constraint(:user)
  end

  def form(attrs \\ %{}), do: changeset(%__MODULE__{}, attrs)

  defp validate_country_in_ceremony(changeset) do
    with id when not is_nil(id) <- get_field(changeset, :ceremony_id),
         country when not is_nil(country) <- get_field(changeset, :country),
         %Ceremony{countries: countries} <- Repo.get(Ceremony, id),
         true <- country in countries do
      changeset
    else
      _ -> add_error(changeset, :country, "is not part of the countries in the ceremony")
    end
  end

  @doc "Returns the list of valid points"
  @spec points :: [integer()]
  def points, do: [1, 2, 3, 4, 5, 6, 7, 8, 10, 12]

  @doc "Get a vote"
  @spec get_by(Keyword.t()) :: t()
  def get_by(clauses) do
    __MODULE__
    |> Repo.get_by(clauses)
    |> case do
      nil -> %__MODULE__{}
      vote -> vote
    end
  end

  @doc "Create or update a vote"
  @spec create(vote()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create(%{ceremony_id: ceremony_id, user_id: user_id, country: country} = attrs) do
    [ceremony_id: ceremony_id, user_id: user_id, country: country]
    |> get_by()
    |> changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc "Delete a vote"
  @spec delete(t()) :: {:ok, t()} | {:error, atom() | Ecto.Changeset.t()}
  def delete(%__MODULE__{id: id}) do
    __MODULE__
    |> Repo.get(id)
    |> case do
      nil -> {:error, :vote_not_found}
      vote -> Repo.delete(vote)
    end
  end

  @doc "Get all votes of a ceremony"
  @spec all(String.t()) :: [t()]
  def all(ceremony_id) do
    Repo.all(
      from(v in __MODULE__,
        where: v.ceremony_id == ^ceremony_id,
        preload: [:user]
      )
    )
  end

  @doc "Get all votes of a user"
  @spec user_votes(String.t(), String.t()) :: [t()]
  def user_votes(ceremony_id, user_id) do
    Repo.all(
      from(v in __MODULE__,
        where: v.ceremony_id == ^ceremony_id and v.user_id == ^user_id
      )
    )
  end

  @doc """
  Compute an aggregate value over all votes of a ceremony

  Aggregate can be `:distinct`, `:count`, `:sum`, `:avg`, `:min` or `:max`, and field any of the field of the schema. Distinct aggregate is only available for `:user_id`.
  """
  @spec total(String.t(), :distinct | :count | :sum | :avg | :min | :max, atom()) :: integer()
  def total(ceremony_id, aggregate \\ :count, field \\ :id)

  def total(ceremony_id, :distinct, :user_id) do
    Repo.one(
      from(v in __MODULE__,
        where: v.ceremony_id == ^ceremony_id,
        select: count(v.user_id, :distinct)
      )
    )
  end

  def total(ceremony_id, aggregate, field) do
    Repo.aggregate(
      from(v in __MODULE__,
        where: v.ceremony_id == ^ceremony_id
      ),
      aggregate,
      field
    )
  end

  @doc """
  Get the leaderboard of a ceremony

  The leaderboard is ordered in descending order by the sum of points.
  """
  @spec leaderboard(String.t()) :: [Ceremony.Result.t()]
  def leaderboard(ceremony_id) do
    Repo.all(
      from(v in __MODULE__,
        where: v.ceremony_id == ^ceremony_id,
        group_by: v.country,
        select: %Ceremony.Result{country: v.country, points: sum(v.points), votes: count(v.id)},
        order_by: [desc: sum(v.points)]
      )
    )
  end

  @doc """
  Get the winner of a ceremony

  The winner is the country with the most points.
  """
  @spec winner(String.t()) :: Ceremony.Winner.t() | nil
  def winner(ceremony_id) do
    Repo.one(
      from(v in __MODULE__,
        where: v.ceremony_id == ^ceremony_id,
        group_by: v.country,
        select: %Ceremony.Winner{country: v.country, points: sum(v.points)},
        order_by: [desc: sum(v.points)],
        limit: 1
      )
    )
  end
end
