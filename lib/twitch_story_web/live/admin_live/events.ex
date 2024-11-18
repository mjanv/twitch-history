defmodule TwitchStoryWeb.AdminLive.Events do
  @moduledoc false

  use TwitchStoryWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
