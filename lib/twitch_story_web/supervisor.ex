defmodule TwitchStoryWeb.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      TwitchStoryWeb.Telemetry,
      # {DNSCluster, query: Application.get_env(:twitch_story, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TwitchStory.PubSub},
      TwitchStoryWeb.Endpoint
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
