defmodule TwitchStoryWeb.GamesLive.Eurovision.Homepage do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Games.Eurovision.Ceremony

  @impl true
  def mount(_params, _session, %{assigns: assigns} = socket) do
    socket
    |> assign(:form, to_form(Ceremony.changeset(%Ceremony{}, %{})))
    |> stream(:ceremonies, Ceremony.all(user_id: assigns.current_user.id))
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"ceremony" => params}, %{assigns: assigns} = socket) do
    params
    |> Map.merge(%{
      "status" => "started",
      "countries" => ["FR", "DE"],
      "user_id" => assigns.current_user.id
    })
    |> Ceremony.create()
    |> case do
      {:ok, ceremony} ->
        socket
        |> put_flash(:info, "Ceremony #{ceremony.name} created")
        |> stream_insert(:ceremonies, ceremony)

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Cannot create ceremony")
        |> assign(:form, to_form(changeset))
    end
    |> then(fn socket -> {:noreply, socket} end)
  end
end
