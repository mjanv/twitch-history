defmodule TwitchStory.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :broadcaster_id, :string
      add :broadcaster_login, :string
      add :broadcaster_name, :string
      add :broadcaster_language, :string

      add :description, :string
      add :tags, {:array, :string}
      add :thumbnail_url, :string
      add :thumbnail, :binary

      timestamps(type: :utc_datetime)
    end

    create unique_index(:channels, [:broadcaster_id])
  end

  def down do
    drop table(:channels)
  end
end
