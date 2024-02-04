defmodule TwitchStoryWeb.DashboardLive.Home do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("search", %{"query" => _query}, socket) do
    {:noreply, socket}
  end
end
