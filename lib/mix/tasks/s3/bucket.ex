defmodule Mix.Tasks.S3.Bucket do
  @moduledoc false

  use Mix.Task

  @shortdoc "List S3 buckets"

  alias TwitchStory.FileStorage

  require Logger

  def run([name]) do
    Application.ensure_all_started(:hackney)

    name
    |> FileStorage.bucket()
    |> case do
      {:ok, contents} ->
        for content <- contents do
          Logger.info("#{content.key} (#{content.size} bytes) - #{content.last_modified}")
        end

      {:error, reason} ->
        Logger.error("Cannot list bucket: #{inspect(reason)}")
    end
  end
end
