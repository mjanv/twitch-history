defmodule TwitchStoryWeb.HomeLive.Schedule do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Twitch.Channels.Channel
  alias TwitchStory.Twitch.Channels.Schedule
  alias TwitchStory.Twitch.FollowedChannel

  def authorized?(_user, _, :index), do: false

  @impl true
  def mount(
        params,
        _session,
        %{assigns: %{current_user: current_user, live_action: live_action}} = socket
      ) do
    schedules =
      case live_action do
        :broadcaster ->
          [broadcaster_id: params["broadcaster_id"]]
          |> Channel.get()
          |> Map.get(:id)
          |> Schedule.get()

        _ ->
          FollowedChannel.all(user_id: current_user.id)
          |> Enum.map(& &1.channel_id)
          |> Schedule.all()
      end

    socket
    |> stream(:schedules, schedules)
    |> then(fn socket -> {:ok, socket} end)
  end
end
