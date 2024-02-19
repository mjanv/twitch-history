defmodule TwitchStory.Twitch do
  @moduledoc false

  alias TwitchStory.Repositories.Filesystem
  alias TwitchStory.Twitch.Requests

  def create_request(path) do
    with %Requests.Metadata{} = metadata <- Requests.Metadata.read(to_charlist(path)),
         {:ok, request} <- Requests.Request.create(metadata),
         :ok <- File.cp!(path, Filesystem.folder(request.request_id)) do
      {:ok, metadata.request_id}
    else
      response -> {:error, response}
    end
  end
end
