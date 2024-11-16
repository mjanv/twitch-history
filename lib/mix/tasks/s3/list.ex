defmodule Mix.Tasks.S3.List do
  @moduledoc false

  use Mix.Task

  @shortdoc "List S3 buckets"

  alias TwitchStory.FileStorage

  require Logger

  def run(_) do
    Application.ensure_all_started(:hackney)

    FileStorage.buckets()
    |> case do
      {:ok, buckets} ->
        Enum.each(buckets, fn bucket -> Logger.info("#{inspect(bucket)}") end)

      {:error, reason} ->
        Logger.error("Cannot list buckets: #{inspect(reason)}")
    end
  end
end
