defmodule Mix.Tasks.Tigris.List do
  @moduledoc false

  use Mix.Task

  @shortdoc "List Tigris buckets"

  alias TwitchStory.FileStorage.Tigris

  require Logger

  def run(_) do
    Application.ensure_all_started(:hackney)

    Tigris.buckets()
    |> case do
      {:ok, buckets} ->
        Enum.each(buckets, fn bucket -> Logger.info("#{inspect(bucket)}") end)

      {:error, reason} ->
        Logger.error("Cannot list buckets: #{inspect(reason)}")
    end
  end
end
