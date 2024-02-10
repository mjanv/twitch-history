defmodule TwitchStoryWeb.DashboardLive.Components.Stats do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  alias TwitchStory.Request.{Commerce, Community, SiteHistory}

  def update(%{file: file}, socket) do
    socket
    |> assign_async(:stats, fn ->
      stats = %{
        follows: file |> Community.Follows.read() |> SiteHistory.n_rows(),
        chat_messages: file |> SiteHistory.ChatMessages.read() |> SiteHistory.n_rows(),
        hours_watched: file |> SiteHistory.MinuteWatched.read() |> SiteHistory.n_rows(60),
        subscriptions: file |> Commerce.Subs.read() |> SiteHistory.n_rows()
      }

      {:ok, %{stats: stats}}
    end)
    |> then(fn socket -> {:ok, socket} end)
  end

  def render(assigns) do
    ~H"""
    <div>
      <.async_result :let={stats} assign={@stats}>
        <:loading></:loading>
        <:failed :let={_reason}></:failed>

        <div id="stats" class="grid grid-cols-1 bg-gray-700/10 sm:grid-cols-2 lg:grid-cols-4">
          <div class="border-t border-white/5 py-6 px-4 sm:px-6 lg:px-8 sm:border-l">
            <p class="text-sm font-medium leading-6 text-gray-400">Hours watched</p>
            <p class="mt-2 flex items-baseline gap-x-2">
              <span class="text-4xl font-semibold tracking-tight text-white">
                <%= stats.hours_watched %>
              </span>
              <span class="text-sm text-gray-400">hours</span>
            </p>
          </div>
          <div class="border-t border-white/5 py-6 px-4 sm:px-6 lg:px-8">
            <p class="text-sm font-medium leading-6 text-gray-400">Number of follows</p>
            <p class="mt-2 flex items-baseline gap-x-2">
              <span class="text-4xl font-semibold tracking-tight text-white">
                <%= stats.follows %>
              </span>
              <span class="text-sm text-gray-400">channels</span>
            </p>
          </div>
          <div class="border-t border-white/5 py-6 px-4 sm:px-6 lg:px-8 lg:border-l">
            <p class="text-sm font-medium leading-6 text-gray-400">Number of messages</p>
            <p class="mt-2 flex items-baseline gap-x-2">
              <span class="text-4xl font-semibold tracking-tight text-white">
                <%= stats.chat_messages %>
              </span>
              <span class="text-sm text-gray-400">messages</span>
            </p>
          </div>
          <div class="border-t border-white/5 py-6 px-4 sm:px-6 lg:px-8 sm:border-l">
            <p class="text-sm font-medium leading-6 text-gray-400">Number of subscriptions</p>
            <p class="mt-2 flex items-baseline gap-x-2">
              <span class="text-4xl font-semibold tracking-tight text-white">
                <%= stats.subscriptions %>
              </span>
              <span class="text-sm text-gray-400">subs</span>
            </p>
          </div>
        </div>
      </.async_result>
    </div>
    """
  end
end
