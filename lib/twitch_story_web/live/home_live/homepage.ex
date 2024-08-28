defmodule TwitchStoryWeb.HomeLive.Homepage do
  @moduledoc false

  use TwitchStoryWeb, :live_view
  use TwitchStoryNative, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {TwitchStoryWeb.Layouts, :root}}
  end
end
