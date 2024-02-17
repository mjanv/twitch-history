defmodule TwitchStoryWeb.Router do
  @moduledoc false

  use TwitchStoryWeb, :router

  import TwitchStoryWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TwitchStoryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user

    # plug SetLocale, gettext: TwitchStoryWeb.Gettext, default_locale: "fr"
    plug Ueberauth
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TwitchStoryWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserLive.RegistrationLive, :new
      live "/users/log_in", UserLive.LoginLive, :new
      live "/users/reset_password", UserLive.ForgotPasswordLive, :new
      live "/users/reset_password/:token", UserLive.ResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TwitchStoryWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserLive.SettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserLive.SettingsLive, :confirm_email
    end
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TwitchStoryWeb.UserAuth, :mount_current_user}] do
      live "/", RootLive.Homepage, :index

      live "/request/new", RequestLive.Upload, :new
      live "/request/overview", RequestLive.Request, :overview
      live "/request/channels", RequestLive.Request, :channels
      live "/request/messages", RequestLive.Messages, :index

      get "/channels", ChannelController, :index
      post "/channels", ChannelController, :create
      get "/channels/:name", ChannelController, :show

      live "/users/confirm/:token", UserLive.ConfirmationLive, :edit
      live "/users/confirm", UserLive.ConfirmationInstructionsLive, :new
    end
  end

  scope "/auth", TwitchStoryWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  if Application.compile_env(:twitch_story, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TwitchStoryWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
