defmodule TwitchStoryWeb.Components.Live.Graph do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  alias TwitchStoryWeb.Graphs.Timeseries

  @impl true
  def update(%{id: id, title: title, data: data, x: x, y: y}, socket) do
    spec = Timeseries.bar(data, title, x, y)

    socket
    |> assign(id: id)
    |> push_event("vega_lite:#{id}:init", %{"spec" => spec})
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="w-full h-full min-h-[400px]"
      phx-hook="VegaLite"
      phx-update="ignore"
      id={@id}
      data-id={@id}
    />
    """
  end
end
