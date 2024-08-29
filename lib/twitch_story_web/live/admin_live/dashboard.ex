defmodule TwitchStoryWeb.AdminLive.Dashboard do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Accounts.User
  alias TwitchStory.Twitch.Channels.Channel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, users: User.all(), roles: User.count_roles(), channels: Channel.all())}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{live_action: :show_user}} = socket) do
    socket
    |> assign(:user, User.get(id))
    |> then(fn socket -> {:noreply, socket} end)
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{live_action: :edit_user}} = socket) do
    user = User.get(id)

    socket
    |> assign(:user, User.get(id))
    |> assign(:form, to_form(User.update_changeset(user, %{})))
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"user" => %{"role" => role}}, %{assigns: %{user: user}} = socket) do
    socket
    |> tap(fn _ -> User.assign_role(user, role) end)
    |> then(fn socket -> {:noreply, socket} end)
  end
end
