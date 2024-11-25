defmodule TwitchStory.Twitch.Histories do
  @moduledoc false

  require Logger

  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.Histories.History
  alias TwitchStory.Twitch.Histories.Metadata
  alias TwitchStory.Twitch.Histories.Summary

  @doc "Create a new history"
  @spec create_history(String.t(), User.t()) :: {:ok, History.t()} | {:error, String.t()}
  def create_history(path, user) do
    with %Metadata{} = metadata <- Metadata.read(path),
         {:ok, history} <- History.create(metadata),
         destination <- Path.join(user.id, history.history_id <> ".zip"),
         :ok <- TwitchStory.file_storage().create(path, destination),
         summary <- Summary.new(TwitchStory.file_storage().bucket(destination)),
         {:ok, history} <- History.update(history, summary: summary) do
      {:ok, history}
    else
      reason ->
        Logger.error("Cannot create history: #{inspect(reason)}")
        {:error, "Cannot create history"}
    end
  end

  @doc "Delete a history"
  @spec delete_history(String.t(), User.t()) :: {:ok, String.t()} | {:error, String.t()}
  def delete_history(history_id, user) do
    with origin <- Path.join(user.id, history_id <> ".zip"),
         :ok <- TwitchStory.file_storage().delete(origin),
         :ok <- History.delete(history_id) do
      {:ok, history_id}
    else
      _ -> {:error, "Cannot delete history"}
    end
  end
end
