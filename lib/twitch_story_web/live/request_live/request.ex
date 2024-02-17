defmodule TwitchStoryWeb.RequestLive.Request do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStoryWeb.RequestLive.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => request_id}, _url, socket) do
    socket
    |> assign(:request_id, request_id)
    |> assign(:file, to_charlist(TwitchStory.Respositories.Filesystem.folder(request_id)))
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("search", %{"query" => _query}, socket) do
    {:noreply, socket}
  end
end
