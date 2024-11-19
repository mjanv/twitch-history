defmodule TwitchStory.FileStorage.Filesystem do
  @moduledoc false

  @behaviour TwitchStory.FileStorage.Behaviour

  require Logger

  @impl true
  def create(origin, destination) do
    with destination <- bucket(destination),
         :ok <- File.mkdir_p(Path.dirname(destination)),
         :ok <- File.cp(origin, destination) do
      :ok
    else
      {:error, reason} ->
        Logger.error("Cannot create directory #{inspect(destination)}: #{inspect(reason)}")
        :error
    end
  end

  @impl true
  def read(origin, destination) do
    origin
    |> bucket()
    |> File.cp(destination)
    |> case do
      :ok ->
        :ok

      {:error, reason} ->
        Logger.error("Cannot read file: #{inspect(reason)}")
        :error
    end
  end

  @impl true
  def delete(origin) do
    origin
    |> File.rm()
    |> case do
      :ok ->
        :ok

      {:error, error} ->
        Logger.error("Cannot delete file: #{inspect(error)}")
        :error
    end
  end

  @spec bucket(String.t()) :: String.t()
  def bucket(request) do
    :twitch_story
    |> Application.get_env(:files)
    |> case do
      nil -> Application.app_dir(:twitch_story, "priv/static/uploads")
      path -> path
    end
    |> Path.join(request)
  end
end
