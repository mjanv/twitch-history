defmodule TwitchStory.Twitch.Workers.Channels.FollowedChannelsWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :twitch,
    max_attempts: 1

  require Logger

  alias TwitchStory.Twitch.Services

  def start(user_id), do: %{step: "start", user_id: user_id} |> __MODULE__.new() |> Oban.insert()

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"step" => "start", "user_id" => user_id}}) do
    with {:ok, channels} <- Services.Channels.find_followed_channels(user_id) do
      jobs =
        channels
        |> Enum.map(&__MODULE__.new(&1))
        |> Oban.insert_all()

      %{job: "end", user_id: user_id}
      |> __MODULE__.new()
      |> Oban.insert()

      TwitchStory.PubSub.broadcast("channels:user:#{user_id}", %SynchronizationPlanned{
        id: user_id,
        name: "followed_channels",
        n: length(jobs)
      })

      :ok
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"broadcaster_id" => broadcaster_id}}) do
    Services.Channels.sync_channel(broadcaster_id)
    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"job" => "end", "user_id" => user_id}}) do
    Services.Channels.sync_followed_channels(user_id)

    TwitchStory.PubSub.broadcast("channels:user:#{user_id}", %SynchronizationFinished{
      id: user_id,
      name: "followed_channels"
    })

    :ok
  end
end
