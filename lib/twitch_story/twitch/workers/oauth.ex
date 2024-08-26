defmodule TwitchStory.Twitch.Workers.OauthWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :twitch,
    max_attempts: 3

  require Logger

  alias TwitchStory.Twitch.Auth
  alias TwitchStory.Twitch.Services

  def start(n), do: %{n: n} |> __MODULE__.new() |> Oban.insert()

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"n" => n}}) do
    n
    |> Auth.OauthToken.expiring?()
    |> Enum.map(&__MODULE__.new(%{id: &1.user_id}))
    |> Oban.insert_all()

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Services.Renewal.renew_access_token(%{id: id})
  end
end
