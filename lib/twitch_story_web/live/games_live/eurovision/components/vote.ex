defmodule TwitchStoryWeb.GamesLive.Eurovision.Components.Vote do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div class="space-y-5 mx-auto max-w-7xl px-4 space-y-4">
       <div id={"#{@id}-items"} phx-hook="Sortable" data-list_id={@id} data-group={@group}>
         <div :for={country <- @countries} id={"#{@id}-#{country.code}"} class="drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0 drag-ghost:bg-zinc-300 drag-ghost:border-0 drag-ghost:ring-0">
           <div class="flex drag-ghost:opacity-0">
             <button type="button" class="w-10">
                <TwitchStoryWeb.Components.Badges.flag height={5} text={false} code={country.code} />
             </button>
             <div class="flex-auto block text-sm leading-6 text-zinc-900">
               <%= country.name %>
             </div>
          </div>
        </div>
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
  def handle_event("save_votes", params, socket) do
    IO.inspect(params)

    {:noreply, socket}
  end
end
