defmodule TwitchStory.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :entries, :map, null: true

      add :channel_id, references(:channels, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
