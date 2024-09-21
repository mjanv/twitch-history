defmodule TwitchStoryWeb.GamesLive.Eurovision.Ceremony do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Games.Eurovision.Ceremony

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      TwitchStory.PubSub.subscribe("eurovision:#{id}")
    end

    ceremony = Ceremony.get(id)

    socket
    |> assign(:ceremony, ceremony)
    |> assign(:form, to_form(Ceremony.Vote.form()))
    |> stream(:votes, Ceremony.votes(ceremony))
    |> assign(:totals, Ceremony.totals(ceremony))
    |> assign(:leaderboard, Ceremony.leaderboard(ceremony))
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_event("start_ceremony", _params, %{assigns: %{ceremony: ceremony}} = socket) do
    ceremony
    |> Ceremony.start()
    |> case do
      {:ok, ceremony} ->
        socket
        |> broadcast(:ceremony_started)
        |> put_flash(:info, "Ceremony started")
        |> assign(:ceremony, ceremony)

      {:error, _} ->
        socket
        |> put_flash(:error, "Cannot complete ceremony")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("pause_ceremony", _params, %{assigns: %{ceremony: ceremony}} = socket) do
    ceremony
    |> Ceremony.pause()
    |> case do
      {:ok, ceremony} ->
        socket
        |> broadcast(:ceremony_paused)
        |> put_flash(:info, "Ceremony paused")
        |> assign(:ceremony, ceremony)

      {:error, _} ->
        socket
        |> put_flash(:error, "Cannot pause ceremony")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("complete_ceremony", _params, %{assigns: %{ceremony: ceremony}} = socket) do
    ceremony
    |> Ceremony.complete()
    |> case do
      {:ok, ceremony} ->
        socket
        |> broadcast(:ceremony_completed)
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
        |> broadcast(:ceremony_cancelled)
        |> put_flash(:info, "Ceremony cancelled")
        |> assign(:ceremony, ceremony)

      {:error, _} ->
        socket
        |> put_flash(:error, "Cannot cancel ceremony")
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(event, %{assigns: assigns} = socket)
      when event in [:vote_registered, :ceremony_completed] do
    ceremony = Ceremony.get(assigns.ceremony.id)

    socket
    |> assign(:ceremony, ceremony)
    |> stream(:votes, Ceremony.votes(ceremony))
    |> assign(:totals, Ceremony.totals(ceremony))
    |> assign(:leaderboard, Ceremony.leaderboard(ceremony))
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp broadcast(%{assigns: %{ceremony: ceremony}} = socket, event) do
    Phoenix.PubSub.broadcast(TwitchStory.PubSub, "eurovision:#{ceremony.id}", event)
    socket
  end
end
