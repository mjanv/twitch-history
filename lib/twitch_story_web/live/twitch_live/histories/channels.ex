defmodule TwitchStoryWeb.TwitchLive.Histories.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStoryWeb.TwitchLive.Histories.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, %{assigns: %{current_user: current_user}} = socket) do
    socket
    |> assign(:id, id)
    |> assign(:file, TwitchStory.file_storage().bucket(Path.join(current_user.id, id <> ".zip")))
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("search", %{"query" => _query}, socket) do
    {:noreply, socket}
  end
end
