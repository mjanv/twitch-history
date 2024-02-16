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

    live "/", RootLive.Homepage, :index

    live "/request/new", RequestLive.Upload, :new
    live "/request/overview", RequestLive.Request, :overview
    live "/request/channels", RequestLive.Request, :channels
    live "/request/messages", RequestLive.Messages, :index

    get "/channels", ChannelController, :index
    post "/channels", ChannelController, :create
    get "/channels/:name", ChannelController, :show
  end

  if Application.compile_env(:twitch_story, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TwitchStoryWeb.Telemetry
    end
  end
end
