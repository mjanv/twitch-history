defmodule TwitchStory.Games.Eurovision.Country.Workers.Etl do
  @moduledoc false

  use Oban.Worker,
    queue: :api,
    max_attempts: 1

  alias TwitchStory.Games.Eurovision.Country.Services.Etl

  def start, do: %{} |> __MODULE__.new() |> Oban.insert()

  @impl Oban.Worker
  def perform(%Oban.Job{}), do: Etl.extract_countries()
end
