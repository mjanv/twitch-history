defmodule TwitchStoryWeb.AdminLive.Users do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  alias TwitchStory.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(users: User.all())
    |> then(fn socket -> {:ok, socket} end)
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{live_action: :show_user}} = socket) do
    socket
    |> assign(:user, User.get(id))
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_params(%{"id" => id}, _, %{assigns: %{live_action: :edit_user}} = socket) do
    user = User.get(id)

    socket
    |> assign(:user, user)
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
    |> redirect(to: ~p"/admin/users")
    |> then(fn socket -> {:noreply, socket} end)
  end
end
