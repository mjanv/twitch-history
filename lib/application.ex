defmodule TwitchStory.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup()
    OpentelemetryLiveView.setup()
    OpentelemetryEcto.setup([:twitch_story, :repo])
    OpentelemetryOban.setup(trace: [:jobs])
    :logger.add_handler(:sentry_handler, Sentry.LoggerHandler, %{})

    children = [
      TwitchStory.Supervisor,
      TwitchStoryWeb.Supervisor
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: TwitchStory.Application.Supervisor
    )
  end

  @impl true
  def config_change(changed, _new, removed) do
    TwitchStoryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
