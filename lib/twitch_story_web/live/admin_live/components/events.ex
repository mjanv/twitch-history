defmodule TwitchStoryWeb.AdminLive.Components.Events do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.stats rows={[{"Total", length(@filtered_events)}]} />

      <div>
        <div class="mt-2">
          <.simple_form for={%{}} phx-target={@myself} phx-change="search">
            <.input
              name="event"
              value=""
              class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
            />
          </.simple_form>
        </div>
      </div>

      <.table id="events" rows={@filtered_events}>
        <:col :let={event} label="Name">
          {TwitchStory.Event.humanize(event, :name)}
        </:col>

        <:col :let={event} label="Id">
          {event.id}
        </:col>

        <:col :let={event} label="Metadata">
          {inspect(event |> Map.from_struct() |> Map.drop([:id, :at]))}
        </:col>

        <:col :let={event} label="Date">
          {TwitchStory.Event.humanize(event, :at)} ago
        </:col>
      </.table>
    </div>
    """
  end

  def mount(socket) do
    {:ok, events} = TwitchStory.EventStore.last(50)
    {:ok, assign(socket, events: events, filtered_events: events)}
  end

  def update(%{id: _id}, socket) do
    {:ok, socket}
  end

  def handle_event("search", %{"event" => search_term}, %{assigns: assigns} = socket) do
    socket
    |> assign(
      :filtered_events,
      Enum.filter(assigns.events, fn event ->
        String.starts_with?(TwitchStory.Event.humanize(event, :name), search_term)
      end)
    )
    |> then(fn socket -> {:noreply, socket} end)
  end
end
