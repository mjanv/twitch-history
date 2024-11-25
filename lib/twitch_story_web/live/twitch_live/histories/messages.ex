defmodule TwitchStoryWeb.TwitchLive.Histories.Messages do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias Phoenix.LiveView.AsyncResult

  alias TwitchStory.Twitch.Histories.SiteHistory
  alias TwitchStoryWeb.TwitchLive.Histories.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> handle_action(socket.assigns.live_action, params)
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_action(%{assigns: %{current_user: current_user}} = socket, _action, %{"id" => id}) do
    file = Path.join(current_user.id, id <> ".zip")

    socket
    |> assign(:id, id)
    |> assign(:file, file)
    |> assign(:raw, AsyncResult.loading())
    |> assign(:messages, AsyncResult.loading())
    |> start_async(:raw, fn -> SiteHistory.ChatMessages.read(file) end)
  end

  def handle_action(socket, _action, _params), do: socket

  @impl true
  def handle_async(:raw, {:ok, response}, socket) do
    socket =
      socket
      |> assign(:raw, AsyncResult.ok(Map.get(socket.assigns, :raw), response))
      |> assign(
        :messages,
        AsyncResult.ok(Map.get(socket.assigns, :messages), Explorer.DataFrame.head(response, 25))
      )

    {:noreply, socket}
  end

  @impl true
  def handle_async(:messages, {:ok, response}, socket) do
    socket =
      socket
      |> assign(:messages, AsyncResult.ok(Map.get(socket.assigns, :messages), response))

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, %{assigns: %{raw: raw}} = socket) do
    socket =
      socket
      |> assign(:query, query)
      |> start_async(:messages, fn ->
        raw.result
        |> SiteHistory.contains(body: query)
        |> Explorer.DataFrame.head(25)
      end)

    {:noreply, socket}
  end

  def enable_toggle(js \\ %JS{}, id) do
    js
    |> JS.toggle_class("bg-gray-200", to: id)
    |> JS.toggle_class("bg-indigo-600", to: id)
    |> JS.toggle_class("translate-x-5", to: "#{id} > span")
    |> JS.toggle_class("translate-x-0", to: "#{id} > span")
  end
end
