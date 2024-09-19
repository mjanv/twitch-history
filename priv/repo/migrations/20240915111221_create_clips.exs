defmodule TwitchStory.Repo.Migrations.CreateClips do
  use Ecto.Migration

  def change do
    create table(:clips) do
      add :twitch_id, :string, null: false
      add :video_id, :string, null: true
      add :title, :string, null: false
      add :created_at, :utc_datetime, null: false

      add :broadcaster_id, :string, null: false

      add :stats, :map, null: false
      add :urls, :map, null: false

      timestamps()
    end

    create unique_index(:clips, [:twitch_id])
    create index(:clips, [:broadcaster_id])
  end
end
