defmodule TwitchStoryWeb.HomeLive.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.FollowedChannel
  alias TwitchStory.Twitch.Workers.Channels.FollowedChannelsWorker

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    TwitchStory.PubSub.subscribe("channels:user:#{current_user.id}")
    {:ok, socket}
  end

  @impl true
  def handle_params(
        _params,
        _uri,
        %{assigns: %{current_user: current_user, live_action: live_action}} = socket
      ) do
    case live_action do
      :sync ->
        socket
        |> tap(fn _ -> FollowedChannelsWorker.start(current_user.id) end)
        |> put_flash(:info, "Sync started...")

      :index ->
        socket
        |> assign(channels: FollowedChannel.all(user_id: current_user.id))
        |> assign(channel_stats: FollowedChannel.count_by_year(current_user.id))
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(%SynchronizationPlanned{name: "followed_channels", n: n}, socket) do
    socket
    |> put_flash(:info, "Planned #{n} channels...")
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(%SynchronizationFinished{name: "followed_channels"}, socket) do
    socket
    |> put_flash(:info, "Finished sync !")
    |> push_navigate(to: "/channels")
    |> then(fn socket -> {:noreply, socket} end)
  end
end
