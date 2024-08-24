defmodule TwitchStory.Games.Eurovision.Vote do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Ceremony
  alias TwitchStory.Games.Eurovision.Result
  alias TwitchStory.Repo

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

  def points, do: [1, 2, 3, 4, 5, 6, 7, 8, 10, 12]

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

  def get_by(attrs) do
    __MODULE__
    |> Repo.get_by(attrs)
    |> case do
      nil -> %__MODULE__{}
      vote -> vote
    end
  end

  def create(%{ceremony_id: ceremony_id, user_id: user_id, country: country} = attrs) do
    [ceremony_id: ceremony_id, user_id: user_id, country: country]
    |> get_by()
    |> case do
      nil -> %__MODULE__{}
      vote -> vote
    end
    |> changeset(attrs)
    |> Repo.insert_or_update()
  end

  def delete(%__MODULE__{id: id}) do
    __MODULE__
    |> Repo.get(id)
    |> case do
      nil -> {:error, :vote_not_found}
      vote -> Repo.delete(vote)
    end
  end

  def all(ceremony_id) do
    from(v in __MODULE__,
      where: v.ceremony_id == ^ceremony_id,
      preload: [:user]
    )
    |> Repo.all()
  end

  def user_votes(ceremony_id, user_id) do
    from(v in __MODULE__,
      where: v.ceremony_id == ^ceremony_id and v.user_id == ^user_id
    )
    |> Repo.all()
  end

  def total_voters(ceremony_id) do
    from(v in __MODULE__,
      where: v.ceremony_id == ^ceremony_id,
      group_by: v.user_id,
      select: 1
    )
    |> Repo.all()
    |> Enum.sum()
  end

  def total_votes(ceremony_id) do
    Repo.aggregate(from(v in __MODULE__, where: v.ceremony_id == ^ceremony_id), :count, :id)
  end

  def total_points(ceremony_id) do
    Repo.aggregate(from(v in __MODULE__, where: v.ceremony_id == ^ceremony_id), :sum, :points)
  end

  def leaderboard(ceremony_id) do
    from(v in __MODULE__,
      where: v.ceremony_id == ^ceremony_id,
      group_by: v.country,
      select: %Result{country: v.country, points: sum(v.points), votes: count(v.id)},
      order_by: [desc: sum(v.points)]
    )
    |> Repo.all()
  end

  def winner(ceremony_id) do
    from(v in __MODULE__,
      where: v.ceremony_id == ^ceremony_id,
      group_by: v.country,
      select: %{country: v.country, points: sum(v.points)},
      order_by: [desc: sum(v.points)],
      limit: 1
    )
    |> Repo.one()
  end
end
