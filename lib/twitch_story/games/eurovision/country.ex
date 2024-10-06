defmodule TwitchStory.Games.Eurovision.Country do
  @moduledoc false

  use TwitchStory.Schema

  alias TwitchStory.Repo

  @type t() :: %__MODULE__{
          name: String.t(),
          code: String.t(),
          binary: String.t()
        }

  schema "eurovision_countries" do
    field :name, :string
    field :code, :string, primary_key: true
    field :binary, :binary

    timestamps()
  end

  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name, :code, :binary])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
  end

  @doc "Count the total number of countries"
  @spec count :: integer()
  def count, do: Repo.count(__MODULE__)

  @doc "Get all countries"
  @spec all :: [t()]
  def all, do: Repo.all(from c in __MODULE__, select: [:code, :name])

  @doc "Get all countries with a given code"
  @spec all(String.t()) :: [t()]
  def all(codes) do
    Repo.all(from c in __MODULE__, where: c.code in ^codes, select: [:code, :name])
  end

  @doc "Get a country"
  @spec get(Keyword.t()) :: t() | nil
  def get(clauses), do: Repo.get_by(__MODULE__, clauses)

  @doc "Create a new country"
  @spec create(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    case get(code: attrs.code) do
      nil -> %__MODULE__{}
      country -> country
    end
    |> changeset(Map.merge(%{binary: <<>>}, attrs))
    |> Repo.insert_or_update()
  end
end
