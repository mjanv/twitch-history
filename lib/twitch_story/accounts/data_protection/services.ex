defmodule TwitchStory.Accounts.DataProtection.Services do
  @moduledoc false

  alias TwitchStory.Accounts.User
  alias TwitchStory.EventStore
  alias TwitchStory.Twitch.FollowedChannel

  @spec extract_user_data(User.t()) :: map() | nil
  def extract_user_data(user) do
    with {:ok, _} <- EventStore.dispatch(%DataExportRequested{id: user.id}),
         user when not is_nil(user) <- User.get(user.id),
         followed_channels <- FollowedChannel.all(user_id: user.id),
         {:ok, events} <- EventStore.all(user.id, true) do
      %{
        user: user,
        events: Enum.map(events, &format_event/1),
        followed_channels: followed_channels
      }
    end
    |> Jason.encode!()
    |> Jason.decode!()
    |> tap(fn _ -> EventStore.dispatch(%DataExportGenerated{id: user.id}) end)
  end

  defp format_event(event) do
    event
    |> Jason.encode!()
    |> Jason.decode!()
    |> Map.put(
      "event",
      event.__struct__
      |> Atom.to_string()
      |> String.replace("Elixir.", "")
    )
  end

  @spec delete_user_data(User.t()) :: :ok | :error
  def delete_user_data(user) do
    case User.delete_user(user) do
      {:ok, _} -> :ok
      _ -> :error
    end
  end
end
