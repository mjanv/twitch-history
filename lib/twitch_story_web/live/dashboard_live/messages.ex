defmodule TwitchStoryWeb.DashboardLive.Messages do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias Phoenix.LiveView.AsyncResult
  alias TwitchStory.Request.SiteHistory.ChatMessages

  alias TwitchStoryWeb.DashboardLive.Components

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

  def handle_action(socket, _action, %{"id" => request_id}) do
    socket
    |> assign(:request_id, request_id)
    |> assign(:file, to_charlist(path_priv(request_id)))
    |> assign(:messages, AsyncResult.loading())
    |> start_async(:messages, fn -> ChatMessages.read(to_charlist(path_priv(request_id))) end)
  end

  def handle_action(socket, _action, _params), do: socket

  @impl true
  def handle_async(:messages, {:ok, response}, socket) do
    socket =
      socket
      |> assign(:messages, AsyncResult.ok(socket.assigns.messages, response))

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => _query}, %{assigns: %{messages: messages}} = socket) do
    socket =
      socket
      |> start_async(:messages, fn ->
        Explorer.DataFrame.shuffle(messages.result)
      end)

    {:noreply, socket}
  end

  defp path_priv(request) do
    :twitch_story
    |> Application.app_dir("priv/static/uploads")
    |> Path.join(request)
    |> then(fn dest -> dest <> ".zip" end)
  end
end
