defmodule TwitchStory.Repo.Migrations.CreateEmotes do
  use Ecto.Migration

  def change do
    create table(:emotes) do
      add :emote_id, :string
      add :name, :string
      add :channel_id, :string
      add :emote_set_id, :string
      add :formats, {:array, :string}
      add :scales, {:array, :string}
      add :themes, {:array, :string}
      add :thumbnail_url, :string
      add :thumbnail, :binary

      # add :channel_id, references(:channels, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:emotes, [:emote_id])
  end

  def down do
    drop table(:emotes)
  end
end
