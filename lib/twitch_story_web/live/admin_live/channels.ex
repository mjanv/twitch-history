defmodule TwitchStoryWeb.AdminLive.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Channels.Channel

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> load_page(1)
    |> assign(:channels, stats())
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_event("infinite-scroll", _params, %{assigns: %{page: page}} = socket) do
    {:noreply, load_page(socket, page + 1)}
  end

  defp load_page(socket, page) do
    socket
    |> assign(:page, page)
    |> stream(:channels, Channel.page(page))
  end

  defp stats do
    [
      {"Channels", Channel.count()},
      {"Last day", Channel.count(1, :day)},
      {"Last week", Channel.count(1, :week)},
      {"Last month", Channel.count(1, :month)}
    ]
  end
end
