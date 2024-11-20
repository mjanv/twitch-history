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
          <div class="flex flex-col items-start justify-between gap-x-8 gap-y-4 bg-gray-900 px-4 py-8 sm:flex-row sm:items-center sm:px-6 lg:px-8">
            <div>
              <div class="flex items-center gap-x-3">
                <div class="flex-none rounded-full bg-purple-400/10 p-1 text-purple-400">
                  <div class="h-4 w-4 rounded-full bg-current"></div>
                </div>
                <h1 class="flex gap-x-3 text-2xl leading-7">
                  <span class="font-semibold text-white">History</span>
                  <span class="text-gray-200">/</span>
                  <span class="font-semibold text-white"><%= @title %></span>
                  <span class="text-gray-200">/</span>
                  <span class="text-gray-100">
                    <%= Timex.format!(metadata.start_time, "{Mfull} {YYYY}") %>
                  </span>
                  <span class="text-gray-100">-</span>
                  <span class="text-gray-100">
                    <%= Timex.format!(metadata.end_time, "{Mfull} {YYYY}") %>
                  </span>
                </h1>
              </div>
            </div>
            <div class="flex items-center gap-x-3">
              <span class="ml-3 text-sm font-normal text-gray-500">
                <span><%= metadata.request_id %></span>
                <span>-</span>
                <span><%= metadata.username %></span>
              </span>
            </div>
          </div>
        </header>

        <nav class="flex overflow-x-auto border-b border-gray-200 bg-purple-100/50 py-5 mb-4">
          <ul
            role="list"
            class="flex min-w-full flex-none gap-x-6 px-4 text-xl font-semibold leading-6 text-gray-800 sm:px-6 lg:px-8"
          >
            <li>
              <.link
                patch={~p"/history/#{metadata.request_id}/overview"}
                class="hover:text-purple-400"
              >
                Overview
              </.link>
            </li>
            <li>
              <.link
                patch={~p"/history/channels?id=#{metadata.request_id}"}
                class="hover:text-purple-400"
              >
                Channels
              </.link>
            </li>
            <li>
              <.link
                patch={~p"/history/messages?id=#{metadata.request_id}"}
                class="hover:text-purple-400"
              >
                Messages
              </.link>
            </li>
          </ul>
        </nav>
      </.async_result>
    </div>
    """
  end
end
