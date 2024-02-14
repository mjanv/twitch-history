defmodule TwitchStory.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Oban.Telemetry.attach_default_logger()

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
