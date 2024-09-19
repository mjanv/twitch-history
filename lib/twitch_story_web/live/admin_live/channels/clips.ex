defmodule TwitchStoryWeb.AdminLive.Channels.Clips do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Channels.Clip

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> load_page(1)
    |> assign(:clips, [{"Clips", Clip.count()}])
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_event("infinite-scroll", _params, %{assigns: %{page: page}} = socket) do
    {:noreply, load_page(socket, page + 1)}
  end

  defp load_page(socket, page) do
    socket
    |> assign(:page, page)
    |> stream(:clips, Clip.page(page))
  end
end
