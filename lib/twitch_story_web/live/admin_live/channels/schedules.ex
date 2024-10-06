defmodule TwitchStoryWeb.AdminLive.Channels.Schedules do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Channels.Schedule

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, %{assigns: %{live_action: live_action}} = socket) do
    case live_action do
      :index ->
        socket
        |> assign(:schedules, stats())
        |> load_page(1)

      :show ->
        socket
        |> assign(:schedule, Schedule.get(id: params["id"]))
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("infinite-scroll", _params, %{assigns: %{page: page}} = socket) do
    {:noreply, load_page(socket, page + 1)}
  end

  defp load_page(socket, page) do
    socket
    |> assign(:page, page)
    |> stream(:schedules, Schedule.page(page))
  end

  defp stats do
    [
      {"Schedules", Schedule.count()},
      {"Last day", Schedule.count(1, :day)},
      {"Last week", Schedule.count(1, :week)},
      {"Last month", Schedule.count(1, :month)}
    ]
  end
end
