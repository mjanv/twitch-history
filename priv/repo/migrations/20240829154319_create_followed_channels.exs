defmodule TwitchStory.Repo.Migrations.CreateFollowedChannel do
  use Ecto.Migration

  def change do
    create table(:followed_channels, primary_key: false) do
      add :user_id, references(:users), primary_key: false
      add :channel_id, references(:channels), primary_key: false

      add :followed_at, :utc_datetime
    end

    create(unique_index(:followed_channels, [:user_id, :channel_id]))
  end
end
