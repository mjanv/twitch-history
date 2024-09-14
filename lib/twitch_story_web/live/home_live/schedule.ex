defmodule TwitchStoryWeb.HomeLive.Schedule do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Accounts.FollowedChannel
  alias TwitchStory.Twitch.Api

  @impl true
  def mount(
        params,
        _session,
        %{assigns: %{current_user: current_user, live_action: live_action}} = socket
      ) do
    pid =
      case live_action do
        :broadcaster ->
          [%{broadcaster_id: params["broadcaster_id"]}]

        _ ->
          FollowedChannel.all(user_id: current_user.id)
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
        channels
        |> Enum.each(fn channel ->
          {:ok, schedule} =
            Api.ChannelApi.schedule(String.to_integer(channel.channel.broadcaster_id))

          send(parent, {:schedule, schedule})
        end)
      end)

    pid
  end
end
