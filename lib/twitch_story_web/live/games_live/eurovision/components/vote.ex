defmodule TwitchStoryWeb.GamesLive.Eurovision.Components.Vote do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="py-4 rounded-lg">
      <div class="mx-auto max-w-full px-4 space-y-3">
        <div id={"#{@id}-items"} phx-hook="Sortable" data-list_id={@id} data-group={@group}>
          <div
            :for={{country, i} <- Enum.with_index(@countries)}
            id={"#{@id}-#{country.code}"}
            class="bg-white border border-gray-300 rounded-lg pt-2 pb-2 pl-5 mb-1"
          >
            <div class="flex items-center space-x-4">
              <button type="button" class="w-16">
                <TwitchStoryWeb.Components.Badges.flag height={16} text={false} code={country.code} />
              </button>
              <div class="flex-auto text-2xl font-bold leading-6 text-gray-900">
                <%= country.name %>
              </div>
              <div class="flex-auto text-2xl font-bold leading-6 text-gray-900">
                <%= Enum.at([12, 10, 9, 8, 7, 6, 4, 3, 2, 1], i, 0) %>
              </div>
            </div>
          </div>
        </div>
        <div class="text-left">
          <.button
            phx-click="save"
            phx-target={@myself}
            class="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 text-3xl font-bold"
          >
            Save
          </.button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event(
        "swap",
        %{"new" => new, "old" => old},
        %{assigns: %{countries: countries}} = socket
      ) do
    socket
    |> assign(:countries, swap(countries, old, new))
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("save", _params, %{assigns: %{countries: countries}} = socket) do
    send(self(), {:saved, countries})

    {:noreply, socket}
  end

  def swap(a, i1, i2) do
    e1 = Enum.at(a, i1)
    e2 = Enum.at(a, i2)

    a
    |> List.replace_at(i1, e2)
    |> List.replace_at(i2, e1)
  end
end
