defmodule Mix.Tasks.Tigris.Bucket do
  @moduledoc false

  use Mix.Task

  @shortdoc "List content of a Tigris bucket"

  alias TwitchStory.FileStorage.Tigris

  require Logger

  def run([name]) do
    Application.ensure_all_started(:hackney)

    name
    |> Tigris.bucket()
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
