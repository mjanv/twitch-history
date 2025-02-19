defmodule TwitchStory.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    Oban.Telemetry.attach_default_logger()

    children = [
      TwitchStory.Repos.Supervisor,
      TwitchStory.Twitch.Supervisor
      # {Oban, Application.fetch_env!(:twitch_story, Oban)}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
