defmodule TwitchStoryWeb.HomeLive.Channels do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Auth
  alias TwitchStory.Twitch.Workers

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    Phoenix.PubSub.subscribe(TwitchStory.PubSub, "channels:user:#{current_user.id}")
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
        {:ok, streams} = Api.UserApi.live_streams(token, current_user.twitch_id)
        assign(socket, channels: [], live_streams: streams)

      :index ->
        current_user.id
        |> User.get()
        |> TwitchStory.Repo.preload(:followed_channels)
        |> Map.get(:followed_channels)
        |> then(fn channels -> assign(socket, channels: channels, live_streams: []) end)
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
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_event("live-sync", _params, %{assigns: %{current_user: current_user}} = socket) do
    {:ok, token} = Auth.OauthToken.get(current_user)
    {:ok, streams} = Api.UserApi.live_streams(token, current_user.twitch_id)

    socket
    |> assign(channels: [], live_streams: streams)
    |> put_flash(:info, "Thumbnails updated...")
    |> then(fn socket -> {:noreply, socket} end)
  end
end
