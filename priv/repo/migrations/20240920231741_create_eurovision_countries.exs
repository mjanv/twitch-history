defmodule TwitchStory.Repo.Migrations.CreateEurovisionCountries do
  use Ecto.Migration

  def change do
    create table(:eurovision_countries) do
      add :name, :string, null: false
      add :code, :string, null: false
      add :binary, :binary, null: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:eurovision_countries, [:code])
  end
end
