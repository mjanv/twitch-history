defmodule TwitchStory.Repo.Migrations.CreateTwitchRequests do
  use Ecto.Migration

  def change do
    create table(:twitch_requests) do
      add :user_id, :string
      add :username, :string
      add :request_id, :string

      add :start_time, :utc_datetime
      add :end_time, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:twitch_requests, [:request_id])
    create index(:twitch_requests, [:user_id])
  end
end
