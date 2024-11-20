defmodule TwitchStoryWeb.TwitchLive.Histories.Components.Stats do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  alias TwitchStory.Twitch.Workers

  def update(%{file: file}, socket) do
    socket
    |> assign_async(:stats, fn -> {:ok, %{stats: Workers.Stats.stats(file)}} end)
    |> then(fn socket -> {:ok, socket} end)
  end

  def render(assigns) do
    ~H"""
    <div>
      <.async_result :let={stats} assign={@stats}>
        <:loading></:loading>
        <:failed :let={_reason}></:failed>

        <div id="stats" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
          <.stat title="Hours watched" value={stats.hours_watched} unit="hours" />
          <.stat title="Channels followed" value={stats.follows} unit="channels" />
          <.stat title="Messages sent" value={stats.chat_messages} unit="messages" />
          <.stat title="Subscriptions bought" value={stats.subscriptions} unit="subs" />
        </div>
      </.async_result>
    </div>
    """
  end
end
