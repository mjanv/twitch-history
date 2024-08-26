defmodule TwitchStory.Repo.Migrations.CreateTwitchOauthTokens do
  use Ecto.Migration

  def change do
    create table(:twitch_oauth_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :access_token, :binary, null: false
      add :refresh_token, :binary, null: false
      add :scopes, {:array, :string}, null: false
      add :expires_at, :timestamp, null: false

      timestamps()
    end

    create index(:twitch_oauth_tokens, [:user_id])
    create unique_index(:twitch_oauth_tokens, [:access_token, :refresh_token])
  end

  def down do
    drop table(:twitch_oauth_tokens)
  end
end
