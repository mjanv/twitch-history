defmodule TwitchStoryWeb.HomeLive.Schedule do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Api
  alias TwitchStory.Twitch.Auth

  @impl true
  def mount(
        params,
        _session,
        %{assigns: %{current_user: current_user, live_action: live_action}} = socket
      ) do
    pid =
      case live_action do
        :broadcaster ->
          [%{id: params["broadcaster_id"]}]

        _ ->
          {:ok, token} = Auth.OauthToken.get(current_user)
          {:ok, channels} = Api.UserApi.live_streams(token, current_user.twitch_id)
          channels
      end
      |> work()

    socket
    |> stream(:schedule, [])
    |> assign(:task, pid)
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_info({:schedule, schedule}, socket) do
    schedule
    |> Enum.reduce(socket, fn segment, socket -> stream_insert(socket, :schedule, segment) end)
    |> then(fn socket -> {:noreply, socket} end)
  end

  defp work(channels) do
    parent = self()

    {:ok, pid} =
      Task.start_link(fn ->
        Enum.each(channels, fn channel ->
          {:ok, schedule} = Api.ChannelApi.schedule(String.to_integer(channel.id))
          send(parent, {:schedule, schedule})
        end)
      end)

    pid
  end
end
