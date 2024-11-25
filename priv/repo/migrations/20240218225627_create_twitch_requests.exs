defmodule TwitchStory.Repo.Migrations.CreateTwitchHistoriesHistory do
  use Ecto.Migration

  def change do
    create table(:twitch_histories_history) do
      add :user_id, :string
      add :username, :string
      add :history_id, :string

      add :start_time, :utc_datetime
      add :end_time, :utc_datetime

      add :summary, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:twitch_histories_history, [:history_id])
    create index(:twitch_histories_history, [:user_id])
  end
end
