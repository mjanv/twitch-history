defmodule TwitchStory.Twitch.Workers.Stats do
  @moduledoc false

  use Oban.Worker,
    queue: :twitch,
    max_attempts: 3

  alias TwitchStory.Twitch.Histories.{Commerce, Community, Metadata, Request, SiteHistory}

  def stats(file) do
    %{
      follows: file |> Community.Follows.read() |> SiteHistory.n_rows(),
      chat_messages: file |> SiteHistory.ChatMessages.read() |> SiteHistory.n_rows(),
      hours_watched: file |> SiteHistory.MinuteWatched.read() |> SiteHistory.n_rows(60),
      subscriptions: file |> Commerce.Subs.read() |> SiteHistory.n_rows()
    }
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"file" => file}}) do
    with metadata <- Metadata.read(to_charlist(file)),
         {:ok, request} <- Request.get(request_id: metadata.request_id),
         {:ok, _} <- Request.update(request, stats: stats(file)) do
      :ok
    else
      _ -> {:snooze, 15}
    end
  end

  def start(file) do
    %{file: file}
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
