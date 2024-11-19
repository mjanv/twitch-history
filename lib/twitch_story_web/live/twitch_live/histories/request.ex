defmodule TwitchStoryWeb.TwitchLive.Histories.Request do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStoryWeb.TwitchLive.Histories.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"id" => request_id},
        _url,
        %{assigns: %{current_user: current_user}} = socket
      ) do
    file = Path.join(current_user.id, request_id <> ".zip")
    file = TwitchStory.file_storage().bucket(file)

    socket
    |> assign(:request_id, request_id)
    |> assign(:file, to_charlist(file))
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("search", %{"query" => _query}, socket) do
    {:noreply, socket}
  end
end
