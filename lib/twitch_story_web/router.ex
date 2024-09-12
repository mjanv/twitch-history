defmodule TwitchStoryWeb.Router do
  @moduledoc false

  use TwitchStoryWeb, :router

  import TwitchStoryWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html", "swiftui"]
    plug :fetch_session
    plug :fetch_live_flash

    plug :put_root_layout,
      html: {TwitchStoryWeb.Layouts, :root},
      swiftui: {TwitchStoryWeb.Layouts.SwiftUI, :root}

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
      live "/account", HomeLive.Account, :index
      live "/channels", HomeLive.Channels, :index
      live "/channels/sync", HomeLive.Channels, :sync
      live "/channels/live", HomeLive.Channels, :live
      live "/schedule", HomeLive.Schedule, :index
      live "/schedule/:broadcaster_id", HomeLive.Schedule, :broadcaster

      live "/users/settings", UserLive.SettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserLive.SettingsLive, :confirm_email

      live "/games/eurovision", GamesLive.Eurovision.Homepage, :index
      live "/games/eurovision/new", GamesLive.Eurovision.Homepage, :new
      live "/games/eurovision/ceremony/:id", GamesLive.Eurovision.Ceremony, :index
      live "/games/eurovision/ceremony/:id/vote", GamesLive.Eurovision.Vote, :index
      live "/games/eurovision/ceremony/:id/leaderboard", GamesLive.Eurovision.Leaderboard, :index

      live "/request/new", RequestLive.Upload, :new
      live "/request/overview", RequestLive.Request, :overview
      live "/request/channels", RequestLive.Request, :channels
      live "/request/messages", RequestLive.Messages, :index
    end
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]

    live_session :require_admin_user,
      on_mount: [{TwitchStoryWeb.UserAuth, :ensure_authenticated}] do
      live "/admin/dashboard", AdminLive.Dashboard, :index
      live "/admin/dashboard/user/:id", AdminLive.Dashboard, :show_user
      live "/admin/dashboard/user/:id/edit", AdminLive.Dashboard, :edit_user
      live "/admin/channels", AdminLive.Channels, :index
      live "/admin/oauth", AdminLive.Oauth, :index
    end
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TwitchStoryWeb.UserAuth, :mount_current_user}] do
      live "/", HomeLive.Homepage, :index

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
