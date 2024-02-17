defmodule TwitchStoryWeb.RootLive.Account do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign(socket, :current_user, session["current_user"])

    {:ok, socket}
  end
end
