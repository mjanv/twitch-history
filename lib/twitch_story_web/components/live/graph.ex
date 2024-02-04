defmodule TwitchStoryWeb.Components.Live.Graph do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  alias TwitchStory.Graphs.Timeseries

  @impl true
  def update(%{title: title, data: result}, socket) do
    g = Timeseries.line(result.result, title)

    socket
    |> assign(id: socket.id)
    |> push_event("vega_lite:#{socket.id}:init", %{"spec" => VegaLite.to_spec(g)})
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      style="width:100%; height: 500px;"
      phx-hook="VegaLite"
      phx-update="ignore"
      id="graph"
      data-id={@id}
    />
    """
  end
end
