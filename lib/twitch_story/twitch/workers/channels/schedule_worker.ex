defmodule TwitchStory.Twitch.Workers.Channels.ScheduleWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :twitch,
    max_attempts: 1

  require Logger

  alias TwitchStory.Twitch.Channels.Channel
  alias TwitchStory.Twitch.Services.Channels

  def start, do: %{job: "start"} |> __MODULE__.new() |> Oban.insert()

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"job" => "start"}}) do
    Channel.all()
    |> Enum.map(&__MODULE__.new(%{broadcaster_id: &1.broadcaster_id}))
    |> Oban.insert_all()

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"broadcaster_id" => broadcaster_id}}) do
    Channels.sync_schedule(broadcaster_id)
  end
end
