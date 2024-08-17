defmodule TwitchStory.Games.Eurovision.Vote do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Ceremony
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
    |> validate_number(:points, greater_than_or_equal_to: 0)
    |> validate_country_in_ceremony()
    |> assoc_constraint(:ceremony)
    |> assoc_constraint(:user)
  end

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

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def all(ceremony_id) do
    from(v in __MODULE__,
      where: v.ceremony_id == ^ceremony_id,
      preload: [:user]
    )
    |> Repo.all()
  end

  def total_points_per_country(ceremony_id) do
    from(v in __MODULE__,
      where: v.ceremony_id == ^ceremony_id,
      group_by: v.country,
      select: %{country: v.country, total: sum(v.points)}
    )
    |> Repo.all()
  end
end
