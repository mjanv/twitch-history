defmodule TwitchStory.Repo.Migrations.CreateEurovisionVotes do
  use Ecto.Migration

  def change do
    create table(:eurovision_votes) do
      add :country, :string, null: false
      add :points, :integer, null: false

      add :ceremony_id, references(:eurovision_ceremonies, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:eurovision_votes, [:ceremony_id])
    create index(:eurovision_votes, [:user_id])
  end
end
