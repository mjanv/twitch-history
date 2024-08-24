defmodule TwitchStory.Twitch do
  @moduledoc false

  alias TwitchStory.Repos.Filesystem
  alias TwitchStory.Twitch.{Api, Channels, Requests, Workers}

  def create_request(path) do
    with %Requests.Metadata{} = metadata <- Requests.Metadata.read(to_charlist(path)),
         {:ok, request} <- Requests.Request.create(metadata),
         dest <- Filesystem.folder(request.request_id),
         :ok <- File.cp!(path, dest),
         {:ok, _} <- Workers.Stats.start(dest) do
      {:ok, metadata.request_id}
    else
      response -> {:error, response}
    end
  end

  def delete_request(request_id) do
    with dest <- Filesystem.folder(request_id),
         :ok <- File.rm!(dest),
         :ok <- Requests.Request.delete(request_id) do
      {:ok, request_id}
    else
      response -> {:error, response}
    end
  end

  defdelegate channels, to: Channels.Channel, as: :list
  def channel_changeset, do: Channels.Channel.change(%Channels.Channel{})

  def create_channel(name) do
    with {:ok, broadcaster_id} <- Api.reverse_search(name),
         {:ok, attrs} <- Api.channel(broadcaster_id),
         {:ok, channel} <- Channels.Channel.create(attrs) do
      {:ok, channel}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
