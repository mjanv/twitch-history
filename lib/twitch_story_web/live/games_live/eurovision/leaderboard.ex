defmodule TwitchStoryWeb.GamesLive.Eurovision.Leaderboard do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Games.Eurovision.Ceremony
  alias TwitchStory.Games.Eurovision.Country

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      TwitchStory.PubSub.subscribe("eurovision:#{id}")
    end

    ceremony = Ceremony.get(id)

    leaderboard =
      ceremony
      |> Ceremony.leaderboard()
      |> Enum.map(fn result -> Map.put(result, :country, Country.get(code: result.country)) end)

    socket
    |> assign(:ceremony, ceremony)
    |> stream_configure(:leaderboard, dom_id: &"leaderboard-#{String.downcase(&1.country.code)}")
    |> stream(:leaderboard, leaderboard)
    |> then(fn socket -> {:ok, socket, layout: {TwitchStoryWeb.Layouts, :root}} end)
  end

  @impl true
  def handle_info(:vote_registered, %{assigns: assigns} = socket) do
    ceremony = Ceremony.get(assigns.ceremony.id)

    leaderboard =
      ceremony
      |> Ceremony.leaderboard()
      |> Enum.map(fn result -> Map.put(result, :country, Country.get(code: result.country)) end)

    socket
    |> stream(:leaderboard, leaderboard)
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(%EurovisionCeremonyCompleted{}, %{assigns: assigns} = socket) do
    ceremony = Ceremony.get(assigns.ceremony.id)

    leaderboard =
      ceremony
      |> Ceremony.leaderboard()
      |> Enum.map(fn result -> Map.put(result, :country, Country.get(code: result.country)) end)

    socket
    |> stream(:leaderboard, leaderboard)
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
