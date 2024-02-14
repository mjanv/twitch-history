defmodule TwitchStory.Twitch.Workers.FetchChannel do
  @moduledoc false

  use Oban.Worker, queue: :twitch

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args}) do
    :ok
  end
end
