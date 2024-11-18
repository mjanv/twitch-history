defmodule TwitchStoryWeb.TwitchLive.Clips do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Channels.Clip

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_page(socket, 1)}
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
