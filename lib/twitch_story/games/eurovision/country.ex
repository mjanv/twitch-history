defmodule TwitchStory.Games.Eurovision.Country do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias TwitchStory.Games.Eurovision.Repositories.Countries

  @primary_key false
  embedded_schema do
    field :name, :string
    field :code, :string
    field :image, :string
  end

  def changeset(%__MODULE__{} = winner, attrs) do
    winner
    |> cast(attrs, [:name, :code, :image])
    |> validate_required([:name, :code])
  end

  def all do
    Countries.all()
    |> Enum.map(&Map.put(&1, :image, "https://flagsapi.com/#{&1.code}/shiny/64.png"))
    |> Enum.map(&struct(__MODULE__, &1))
  end

  def get(code) do
    Countries.all()
    |> Enum.find(nil, fn c -> c.code == code end)
    |> then(fn
      nil ->
        nil

      country ->
        country
        |> then(&Map.put(&1, :image, "https://flagsapi.com/#{&1.code}/shiny/64.png"))
        |> then(&struct(__MODULE__, &1))
    end)
  end
end
