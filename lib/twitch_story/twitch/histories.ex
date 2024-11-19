defmodule TwitchStory.Twitch.Histories do
  @moduledoc false

  require Logger

  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.Histories
  alias TwitchStory.Twitch.Workers

  @doc "Create a new history"
  @spec create_history(String.t(), User.t()) :: {:ok, String.t()} | {:error, String.t()}
  def create_history(path, user) do
    with %Histories.Metadata{} = metadata <- Histories.Metadata.read(to_charlist(path)),
         {:ok, request} <- Histories.Request.create(metadata),
         destination <- Path.join(user.id, request.request_id <> ".zip"),
         :ok <- TwitchStory.file_storage().create(path, destination),
         {:ok, _} <- Workers.Stats.start(destination) do
      {:ok, metadata.request_id}
    else
      reason ->
        Logger.error("Cannot create history: #{inspect(reason)}")
        {:error, "Cannot create history"}
    end
  end

  @doc "Delete a history"
  @spec delete_history(String.t(), User.t()) :: {:ok, String.t()} | {:error, String.t()}
  def delete_history(request_id, user) do
    with origin <- Path.join(user.id, request_id <> ".zip"),
         :ok <- TwitchStory.file_storage().delete(origin),
         :ok <- Histories.Request.delete(request_id) do
      {:ok, request_id}
    else
      _ -> {:error, "Cannot delete history"}
    end
  end
end
