defmodule TwitchStoryWeb.TwitchLive.Histories.Components.Metadata do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  alias TwitchStory.Twitch.Histories.Metadata

  def update(%{file: file, title: title}, socket) do
    socket
    |> assign(:title, title)
    |> assign_async(:metadata, fn -> {:ok, %{metadata: Metadata.read(file)}} end)
    |> then(fn socket -> {:ok, socket} end)
  end

  def render(assigns) do
    ~H"""
    <div>
      <.async_result :let={metadata} assign={@metadata}>
        <:loading></:loading>
        <:failed :let={_reason}></:failed>
        <header>
          <!-- Secondary navigation -->
          <nav class="flex overflow-x-auto border-b border-white/10 py-4">
            <ul
              role="list"
              class="flex min-w-full flex-none gap-x-6 px-4 text-sm font-semibold leading-6 text-gray-400 sm:px-6 lg:px-8"
            >
              <li>
                <a href="#" class="text-indigo-400">Overview</a>
              </li>
              <li>
                <.link patch={~p"/history/channels?id=#{metadata.request_id}"} class="">
                  Channels
                </.link>
              </li>
              <li>
                <.link patch={~p"/history/messages?id=#{metadata.request_id}"} class="">
                  Messages
                </.link>
              </li>
            </ul>
          </nav>
          <!-- Heading -->
          <div class="flex flex-col items-start justify-between gap-x-8 gap-y-4 bg-gray-800 px-4 py-4 sm:flex-row sm:items-center sm:px-6 lg:px-8">
            <div>
              <div class="flex items-center gap-x-3">
                <div class="flex-none rounded-full bg-purple-400/10 p-1 text-purple-400">
                  <div class="h-2 w-2 rounded-full bg-current"></div>
                </div>
                <h1 class="flex gap-x-3 text-base leading-7">
                  <span class="font-semibold text-white">Twitch</span>
                  <span class="text-gray-600">/</span>
                  <span class="font-semibold text-white"><%= metadata.username %></span>
                  <span class="text-gray-600">/</span>
                  <span class="font-semibold text-white"><%= @title %></span>
                </h1>
              </div>
              <p class="mt-2 text-xs leading-6 text-gray-400">
                Request id: <%= metadata.request_id %>
              </p>
            </div>
            <div class="order-first flex-none rounded-full bg-indigo-400/10 px-2 py-1 text-xs font-medium text-indigo-400 ring-1 ring-inset ring-indigo-400/30 sm:order-none">
              <%= inspect(metadata.start_time) %> - <%= inspect(metadata.end_time) %>
            </div>
          </div>
        </header>
      </.async_result>
    </div>
    """
  end
end
