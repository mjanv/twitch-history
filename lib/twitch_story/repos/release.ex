defmodule TwitchStory.Repos.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """

  alias EventStore.Tasks

  @app :twitch_story

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    for event_store <- event_stores() do
      config = event_store.config()
      :ok = Tasks.Create.exec(config, [])
      :ok = Tasks.Init.exec(config, [])
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)
  defp event_stores, do: Application.fetch_env!(@app, :event_stores)
  defp load_app, do: Application.load(@app)
end
