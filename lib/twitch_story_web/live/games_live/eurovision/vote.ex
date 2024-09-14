defmodule TwitchStoryWeb.GamesLive.Eurovision.Vote do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Games.Eurovision.Ceremony

  @impl true
  def mount(%{"id" => id}, _session, %{assigns: assigns} = socket) do
    if connected?(socket) do
      TwitchStory.PubSub.subscribe("eurovision:#{id}")
    end

    ceremony = Ceremony.get(id)

    socket
    |> assign(:ceremony, ceremony)
    |> assign(:votes, Ceremony.user_votes(ceremony, assigns.current_user))
    |> then(fn socket -> {:ok, socket, layout: {TwitchStoryWeb.Layouts, :root}} end)
  end

  @impl true
  def handle_info({:saved, countries}, %{assigns: assigns} = socket) do
    assigns.ceremony
    |> Ceremony.add_votes(
      countries
      |> Enum.with_index()
      |> Enum.map(fn {%{code: code}, i} ->
        %{
          country: code,
          points: Enum.at([12, 10, 9, 8, 7, 6, 4, 3, 2, 1], i, 0),
          user_id: assigns.current_user.id
        }
      end)
    )
    |> case do
      {:ok, votes} ->
        socket
        |> put_flash(:info, "Votes registered")
        |> broadcast(:vote_registered)
        |> assign(:votes, votes)
        |> assign(:leaderboard, Ceremony.leaderboard(assigns.ceremony))

      {:error, _} ->
        socket
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(event, %{assigns: assigns} = socket)
      when event in [:ceremony_paused, :ceremony_completed, :ceremony_cancelled] do
    socket
    |> assign(:ceremony, Ceremony.get(assigns.ceremony.id))
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_info(:ceremony_started, %{assigns: assigns} = socket) do
    ceremony = Ceremony.get(assigns.ceremony.id)

    socket
    |> assign(:ceremony, ceremony)
    |> assign(:votes, Ceremony.user_votes(ceremony, assigns.current_user))
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
