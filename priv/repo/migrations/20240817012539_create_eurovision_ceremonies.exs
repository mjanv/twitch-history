defmodule TwitchStory.Repo.Migrations.CreateEurovisionCeremonies do
  use Ecto.Migration

  def change do
    create table(:eurovision_ceremonies) do
      add :name, :string, null: false
      add :status, :string, default: "started"
      add :countries, {:array, :string}, null: false
      add :winner, :map

      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:eurovision_ceremonies, [:user_id])
  end
end
