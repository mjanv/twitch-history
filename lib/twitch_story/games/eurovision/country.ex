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

  def all do
    Repo.all(
      from c in __MODULE__,
        select: [:code, :name]
    )
  end

  def all(codes) do
    Repo.all(
      from c in __MODULE__,
        where: c.code in ^codes,
        select: [:code, :name]
    )
  end

  def get(code) do
    Repo.get_by(__MODULE__, code: code)
  end

  def create(attrs) do
    case Repo.get_by(__MODULE__, code: attrs.code) do
      nil -> %__MODULE__{}
      country -> country
    end
    |> changeset(Map.merge(%{binary: <<>>}, attrs))
    |> Repo.insert_or_update()
  end

  def count, do: Repo.count(__MODULE__)
end
