defmodule TwitchStoryWeb.Components.Background do
  @moduledoc false

  use Phoenix.LiveComponent

  @impl true
  def mount(socket) do
    if connected?(socket) do
      send_update_after(__MODULE__, %{action: :tick, id: "hero"}, 100)
    end

    points = random_start(10)
    {:ok, assign(socket, points: points, string: to_clip_path(points))}
  end

  @impl true
  def update(%{action: :tick, id: id}, %{assigns: %{points: points}} = socket) do
    send_update_after(__MODULE__, %{action: :tick, id: id}, 100)
    points = next(points)
    {:ok, assign(socket, points: points, string: to_clip_path(points))}
  end

  def update(_assigns, socket) do
    {:ok, socket}
  end

  defp random_start(n) do
    Enum.map(1..n, fn _ -> {:rand.uniform(100), :rand.uniform(100)} end)
  end

  # defp start() do
  #   [{0, 0}, {0, 100}, {50, 50}, {100, 100}, {50, 50}, {100, 0}]
  # end

  def next(points) do
    Enum.map(points, fn {x, y} -> {noise(x), noise(y)} end)
  end

  defp to_clip_path(points) do
    points
    |> Enum.map_join(", ", fn {x, y} -> "#{x}% #{y}%" end)
    |> then(fn s -> "clip-path: polygon(#{s})" end)
  end

  defp noise(x) do
    x
    |> Kernel.+(r(-1, 1))
    |> min(100)
    |> max(0)
  end

  def r(a, b), do: :rand.uniform() * (b - a) + a

  @impl true
  def render(assigns) do
    ~H"""
    <div class="absolute inset-x-0 -z-10 transform-gpu overflow-hidden blur-3xl">
      <div
        class="relative aspect-[1155/678] left-[calc(50%-30rem)] w-[72.1875rem] bg-gradient-to-tr from-[#ff80b5] to-[#9089fc] opacity-20"
        style={@string}
      >
      </div>
    </div>
    """
  end
end
