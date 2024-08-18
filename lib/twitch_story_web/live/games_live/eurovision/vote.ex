defmodule TwitchStoryWeb.GamesLive.Eurovision.Vote do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Games.Eurovision.Ceremony

  @impl true
  def mount(%{"id" => id}, _session, %{assigns: assigns} = socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(TwitchStory.PubSub, "eurovision:#{id}")
    end

    ceremony = Ceremony.get(id)

    socket
    |> assign(:ceremony, ceremony)
    |> assign(:votes, Ceremony.user_votes(ceremony, assigns.current_user))
    |> then(fn socket -> {:ok, socket, layout: {TwitchStoryWeb.Layouts, :root}} end)
  end

  @impl true
  def handle_event("save_votes", params, %{assigns: assigns} = socket) do
    IO.inspect(params)

    assigns.ceremony
    |> Ceremony.add_vote(
      params
      |> string_to_atom_keys()
      |> Map.put(:user_id, assigns.current_user.id)
    )
    |> case do
      {:ok, vote} ->
        socket
        |> put_flash(:info, "Vote registered")
        |> broadcast(:vote_registered)
        |> stream_insert(:votes, vote)
        |> assign(:leaderboard, Ceremony.leaderboard(assigns.ceremony))

      {:error, _} ->
        socket
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  defp broadcast(%{assigns: %{ceremony: ceremony}} = socket, event) do
    Phoenix.PubSub.broadcast(TwitchStory.PubSub, "eurovision:#{ceremony.id}", event)
    socket
  end

  defp string_to_atom_keys(m) do
    for {k, v} <- m, into: %{}, do: {String.to_atom(k), v}
  end
end
