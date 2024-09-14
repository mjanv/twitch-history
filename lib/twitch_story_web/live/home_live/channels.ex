defmodule TwitchStoryWeb.HomeLive.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Accounts.FollowedChannel
  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Auth
  alias TwitchStory.Twitch.Workers

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
    {:ok, token} = Auth.OauthToken.get(current_user)

    case live_action do
      :sync ->
        Workers.ChannelWorker.start(current_user.id)

        socket
        |> put_flash(:info, "Sync started...")

      :live ->
        {:ok, streams} = Api.UserApi.live_streams(token)
        assign(socket, channels: [], live_streams: streams)

      :index ->
        assign(socket, channels: FollowedChannel.all(user_id: current_user.id), live_streams: [])
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info({:sync_planned, n}, socket) do
    socket
    |> put_flash(:info, "Planned #{n} channels...")
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_info(:sync_finished, socket) do
    socket
    |> put_flash(:info, "Finished sync !")
    |> push_navigate(to: "/channels")
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("live-sync", _params, %{assigns: %{current_user: current_user}} = socket) do
    {:ok, token} = Auth.OauthToken.get(current_user)
    {:ok, streams} = Api.UserApi.live_streams(token)

    socket
    |> assign(channels: [], live_streams: streams)
    |> put_flash(:info, "Thumbnails updated...")
    |> then(fn socket -> {:noreply, socket} end)
  end
end
