defmodule TwitchStoryWeb.GamesLive.Eurovision.Ceremony do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Games.Eurovision.{Ceremony, Vote}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    ceremony = Ceremony.get(id)

    socket
    |> assign(:ceremony, ceremony)
    |> assign(:form, to_form(Vote.changeset(%Vote{}, %{})))
    |> stream(:votes, Ceremony.votes(ceremony))
    |> assign(:results, Ceremony.results(ceremony))
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_event("complete_ceremony", _params, %{assigns: %{ceremony: ceremony}} = socket) do
    ceremony
    |> Ceremony.complete()
    |> case do
      {:ok, ceremony} ->
        socket
        |> put_flash(:info, "Ceremony completed")
        |> assign(:ceremony, ceremony)

      {:error, _} ->
        socket
        |> put_flash(:error, "Cannot complete ceremony")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("cancel_ceremony", _params, %{assigns: %{ceremony: ceremony}} = socket) do
    ceremony
    |> Ceremony.cancel()
    |> case do
      {:ok, ceremony} ->
        socket
        |> put_flash(:info, "Ceremony cancelled")
        |> assign(:ceremony, ceremony)

      {:error, _} ->
        socket
        |> put_flash(:error, "Cannot cancel ceremony")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("validate_vote", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_vote", %{"vote" => params}, %{assigns: assigns} = socket) do
    assigns.ceremony
    |> Ceremony.add_vote(
      params
      |> string_to_atom_keys()
      |> Map.put(:user_id, assigns.current_user.id)
    )
    |> case do
      {:ok, vote} ->
        socket
        |> put_flash(:info, "Voted registered")
        |> stream_insert(:votes, vote)
        |> assign(:results, Ceremony.results(assigns.ceremony))

      {:error, _} ->
        socket
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  defp string_to_atom_keys(m) do
    for {k, v} <- m, into: %{}, do: {String.to_atom(k), v}
  end
end
