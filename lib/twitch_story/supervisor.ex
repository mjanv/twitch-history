defmodule TwitchStory.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      TwitchStory.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:twitch_story, :ecto_repos),
       skip: System.get_env("SKIP_MIGRATIONS") == "true"},
      {Oban, Application.fetch_env!(:twitch_story, Oban)}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
