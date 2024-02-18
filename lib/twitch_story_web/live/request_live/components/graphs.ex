defmodule TwitchStoryWeb.RequestLive.Components.Graphs do
  @moduledoc false

  use TwitchStoryWeb, :live_component

  alias TwitchStory.Requests.SiteHistory

  def update(%{file: file}, socket) do
    socket
    |> assign_async([:chat_messages, :minute_watched], fn ->
      graphs = %{
        chat_messages:
          file
          |> SiteHistory.ChatMessages.read()
          |> SiteHistory.ChatMessages.group_month_year()
          |> SiteHistory.nominal_date_column(),
        minute_watched:
          file
          |> SiteHistory.MinuteWatched.read()
          |> SiteHistory.MinuteWatched.group_month_year()
          |> SiteHistory.nominal_date_column()
      }

      {:ok, graphs}
    end)
    |> then(fn socket -> {:ok, socket} end)
  end

  def render(assigns) do
    ~H"""
    <div>
      <.async_result :let={_minute_watched} assign={@minute_watched}>
        <:loading></:loading>
        <:failed :let={_reason}></:failed>
        <div class="block">
          <.live_component
            module={TwitchStoryWeb.Components.Live.Graph}
            id="hours"
            title="Hours per month"
            data={@minute_watched}
          />
        </div>
      </.async_result>

      <.async_result :let={_chat_messages} assign={@chat_messages}>
        <:loading></:loading>
        <:failed :let={_reason}></:failed>
        <div class="block">
          <.live_component
            module={TwitchStoryWeb.Components.Live.Graph}
            id="messages"
            title="Messages per month"
            data={@chat_messages}
          />
        </div>
      </.async_result>
    </div>
    """
  end
end
