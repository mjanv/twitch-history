defmodule TwitchStoryWeb.GamesLive.Eurovision.Homepage do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Games.Eurovision.Ceremony

  @impl true
  def mount(_params, _session, %{assigns: assigns} = socket) do
    if connected?(socket) do
      TwitchStory.PubSub.subscribe("eurovision")
    end

    socket
    |> stream(:ceremonies, Ceremony.all(user_id: assigns.current_user.id))
    |> stream(:active_ceremonies, Ceremony.actives())
    |> stream(:past_ceremonies, Ceremony.pasts())
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket.assigns.live_action
    |> case do
      :index ->
        socket
        |> assign(:form, nil)

      :new ->
        socket
        |> assign(:form, to_form(Ceremony.form()))
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"ceremony" => params}, %{assigns: assigns} = socket) do
    countries =
      params
      |> Enum.filter(fn {k, v} -> String.starts_with?(k, "country:") and v == "true" end)
      |> Enum.map(fn {k, _} -> k |> String.split(":") |> List.last() |> String.upcase() end)

    params
    |> Map.merge(%{
      "countries" => countries,
      "user_id" => assigns.current_user.id
    })
    |> string_to_atom_keys()
    |> Ceremony.create()
    |> case do
      {:ok, ceremony} ->
        socket
        |> broadcast(:ceremony_created)
        |> put_flash(:info, "Ceremony #{ceremony.name} created")
        |> stream_insert(:ceremonies, Ceremony.get(ceremony.id))
        |> push_navigate(to: ~p"/games/eurovision/ceremony/#{ceremony}")

      {:error, _changeset} ->
        socket
        |> put_flash(:error, "Cannot create ceremony")
        |> push_patch(to: ~p"/games/eurovision")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    id
    |> Ceremony.get()
    |> Ceremony.delete()
    |> case do
      {:ok, ceremony} ->
        socket
        |> broadcast(:ceremony_deleted)
        |> stream_delete(:ceremonies, ceremony)
        |> put_flash(:info, "Ceremony #{ceremony.name} deleted")

      {:error, _} ->
        socket
        |> put_flash(:error, "Cannot delete ceremony")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(_event, socket) do
    {:noreply, socket}
  end

  defp string_to_atom_keys(m) do
    for {k, v} <- m, into: %{}, do: {String.to_atom(k), v}
  end

  defp broadcast(socket, event) do
    Phoenix.PubSub.broadcast(TwitchStory.PubSub, "eurovision", event)
    socket
  end
end
