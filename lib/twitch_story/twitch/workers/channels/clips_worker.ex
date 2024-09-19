defmodule TwitchStory.Twitch.Workers.Channels.ClipsWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :twitch,
    max_attempts: 1

  require Logger

  alias TwitchStory.Twitch.Channels.Channel
  alias TwitchStory.Twitch.Services.Channels

  def start(hour), do: %{job: "start", hour: hour} |> __MODULE__.new() |> Oban.insert()

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"job" => "start", "hour" => hour}}) do
    Channel.all()
    |> Enum.map(&__MODULE__.new(%{broadcaster_id: &1.broadcaster_id, hour: hour}))
    |> Oban.insert_all()

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"broadcaster_id" => broadcaster_id, "hour" => hour}}) do
    Channels.sync_last_clips(broadcaster_id, hour: hour)

    :ok
  end
end
