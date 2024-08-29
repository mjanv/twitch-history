defmodule TwitchStory.Twitch.Workers.ChannelWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :twitch,
    max_attempts: 1

  require Logger

  alias TwitchStory.Twitch.Services

  def start(user_id), do: %{user_id: user_id} |> __MODULE__.new() |> Oban.insert()

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    with {:ok, channels} <- Services.Channels.sync_channels(user_id) do
      jobs =
        channels
        |> Enum.map(&__MODULE__.new(&1))
        |> Enum.take(2)
        |> Oban.insert_all()

      Phoenix.PubSub.broadcast(
        TwitchStory.PubSub,
        "channels:user:#{user_id}",
        {:sync_planned, length(jobs)}
      )

      :ok
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"broadcaster_id" => id}}) do
    Services.Channels.sync_channel(id)
    :ok
  end
end
