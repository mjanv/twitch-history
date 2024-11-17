defmodule TwitchStoryWeb.HomeLive.Channels.Live do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Auth

  def authorized?(user, _), do: FeatureFlag.enabled?(:live, user)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, %{assigns: %{current_user: current_user}} = socket) do
    sync_live_streams(socket, current_user)
  end

  @impl true
  def handle_info(:live_sync, %{assigns: %{current_user: current_user}} = socket) do
    sync_live_streams(socket, current_user)
  end

  def sync_live_streams(socket, user) do
    with _ <- Process.send_after(self(), :live_sync, 30_000),
         {:ok, token} <- Auth.OauthToken.get(user),
         {:ok, streams} <- Api.UserApi.live_streams(token) do
      {:noreply, assign(socket, live_streams: streams)}
    else
      _ -> {:noreply, socket}
    end
  end
end
