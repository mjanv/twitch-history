defmodule TwitchStory.Games.Eurovision.Ceremony do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias TwitchStory.Accounts.User
  alias TwitchStory.Games.Eurovision.Vote
  alias TwitchStory.Repo

  schema "eurovision_ceremonies" do
    field :name, :string
    field :countries, {:array, :string}

    belongs_to :user, User
    has_many :votes, Vote
    has_many :voters, through: [:votes, :user]

    timestamps(type: :utc_datetime)
  end

  def changeset(ceremony, attrs) do
    ceremony
    |> cast(attrs, [:name, :countries, :user_id])
    |> validate_required([:name, :countries, :user_id])
    |> assoc_constraint(:user)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def add_vote(%__MODULE__{id: id}, vote_attrs) do
    vote_attrs
    |> Map.merge(%{ceremony_id: id})
    |> Vote.create()
  end

  def votes(ceremony) do
    Vote.all(ceremony.id)
  end

  def voters(ceremony) do
    __MODULE__
    |> Repo.get!(ceremony.id)
    |> Repo.preload(:voters)
    |> Map.get(:voters)
  end

  def total_points_per_country(ceremony) do
    Vote.total_points_per_country(ceremony.id)
  end
end
