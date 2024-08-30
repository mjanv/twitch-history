defmodule TwitchStory.Repo.Migrations.CreateFollowedChannel do
  use Ecto.Migration

  def change do
    create table("followed_channels", primary_key: false) do
      add :user_id, references(:users)
      add :channel_id, references(:channels)

      add :followed_at, :utc_datetime
    end
  end
end
