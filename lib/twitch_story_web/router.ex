defmodule TwitchStoryWeb.Router do
  @moduledoc false

  use TwitchStoryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TwitchStoryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TwitchStoryWeb do
    pipe_through :browser

    live "/", DashboardLive.Home, :new
    live "/request/:id", DashboardLive.Home, :show
    live "/request/channels/:id", DashboardLive.Home, :channels
    live "/request/messages/:id", DashboardLive.Messages, :index
  end

  if Application.compile_env(:twitch_story, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TwitchStoryWeb.Telemetry
    end
  end
end
