defmodule TwitchStory.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false, collate: :nocase
      add :provider, :string, null: false
      add :role, :string, default: "viewer"

      add :hashed_password, :string, null: true
      add :confirmed_at, :naive_datetime, null: true

      add :twitch_id, :string, null: true
      add :twitch_avatar, :string, null: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false, size: 32
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end

  def down do
    drop table(:users_tokens)
    drop table(:users)
  end
end
