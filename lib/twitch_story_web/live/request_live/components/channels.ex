defmodule TwitchStoryWeb.RequestLive.Components.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  alias TwitchStory.Request.Channels

  def update(%{file: file}, socket) do
    socket
    |> assign_async(:channels, fn -> {:ok, %{channels: Channels.channels(file)}} end)
    |> then(fn socket -> {:ok, socket} end)
  end

  def render(assigns) do
    ~H"""
    <div>
      <.async_result :let={channels} assign={@channels}>
        <div class="border-t border-white/10 pt-11">
          <table class="mt-6 w-full whitespace-nowrap text-left">
            <colgroup>
              <col class="w-full sm:w-4/12" />
              <col class="lg:w-2/12" />
              <col class="lg:w-2/12" />
              <col class="lg:w-2/12" />
              <col class="lg:w-2/12" />
            </colgroup>
            <thead class="border-b border-white/10 text-sm leading-6 text-white">
              <tr>
                <th scope="col" class="py-2 pl-4 pr-8 font-semibold sm:pl-6 lg:pl-8">Channel</th>
                <th scope="col" class="hidden py-2 pl-0 pr-8 font-semibold sm:table-cell">
                  Hours watched
                </th>
                <th
                  scope="col"
                  class="py-2 pl-0 pr-4 text-right font-semibold sm:pr-8 sm:text-left lg:pr-20"
                >
                  Messages
                </th>
                <th scope="col" class="hidden py-2 pl-0 pr-8 font-semibold md:table-cell lg:pr-20">
                  Follow
                </th>
                <th
                  scope="col"
                  class="hidden py-2 pl-0 pr-4 text-right font-semibold sm:table-cell sm:pr-6 lg:pr-8"
                >
                  Subscriptions
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <%= for row <- Explorer.DataFrame.to_rows(channels, atom_keys: true) do %>
                <tr>
                  <td class="py-4 pl-4 pr-8 sm:pl-6 lg:pl-8">
                    <div class="flex items-center gap-x-4">
                      <img
                        src="https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                        alt=""
                        class="h-8 w-8 rounded-full bg-gray-800"
                      />
                      <.link patch={~p"/"} class="truncate text-sm font-medium leading-6 text-white">
                        <%= row.channel %>
                      </.link>
                    </div>
                  </td>
                  <td class="hidden py-4 pl-0 pr-4 sm:table-cell sm:pr-8">
                    <div class="flex gap-x-3">
                      <div class="font-mono text-sm leading-6 text-gray-400">
                        <%= row.hours %> hours
                      </div>
                    </div>
                  </td>
                  <td class="py-4 pl-0 pr-4 text-sm leading-6 sm:pr-8 lg:pr-20">
                    <div class="flex gap-x-3">
                      <div class="font-mono text-sm leading-6 text-gray-400">
                        <%= row.messages || 0 %> messages
                      </div>
                    </div>
                  </td>
                  <td class="hidden py-4 pl-0 pr-8 text-sm leading-6 text-gray-400 md:table-cell lg:pr-20">
                    <div class="flex items-center justify-end gap-x-2 sm:justify-start">
                      <%= if row.follow do %>
                        <div class="flex-none rounded-full p-1 text-green-400 bg-green-400/10">
                          <div class="h-1.5 w-1.5 rounded-full bg-current"></div>
                        </div>
                        <div class="hidden text-white sm:block">
                          <%= row.follow %>
                        </div>
                      <% else %>
                        <div class="flex-none rounded-full p-1 text-red-400 bg-red-400/10">
                          <div class="h-1.5 w-1.5 rounded-full bg-current"></div>
                        </div>
                        <div class="hidden text-white sm:block">-</div>
                      <% end %>
                    </div>
                  </td>
                  <td class="hidden py-4 pl-0 pr-4 text-right text-sm leading-6 text-gray-400 sm:table-cell sm:pr-6 lg:pr-8">
                    0
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </.async_result>
    </div>
    """
  end
end
