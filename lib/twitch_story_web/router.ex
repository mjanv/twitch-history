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
    # , %{"content-security-policy" => "default-src 'self'"}
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_oauth_token

    # plug SetLocale, gettext: TwitchStoryWeb.Gettext, default_locale: "fr"
    plug Ueberauth
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TwitchStoryWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", AccountsLive.RegistrationLive, :new
      live "/users/log_in", AccountsLive.LoginLive, :new
      live "/users/reset_password", AccountsLive.ForgotPasswordLive, :new
      live "/users/reset_password/:token", AccountsLive.ResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {TwitchStoryWeb.UserAuth, :ensure_authenticated},
        {TwitchStoryWeb.UserAuth, :ensure_authorized}
      ] do
      live "/users/settings", AccountsLive.SettingsLive, :edit
      live "/users/settings/confirm_email/:token", AccountsLive.SettingsLive, :confirm_email

      live "/account", AccountsLive.Account, :index
      live "/channels", TwitchLive.Channels, :index
      live "/channels/sync", TwitchLive.Channels, :sync
      live "/channels/live", TwitchLive.Channels.Live, :index
      live "/channels/:broadcaster_id", TwitchLive.Channels.Channel, :index
      live "/schedule", TwitchLive.Schedule, :index
      live "/schedule/:broadcaster_id", TwitchLive.Schedule, :broadcaster
      live "/clips", TwitchLive.Clips, :index

      live "/history", TwitchLive.Histories, :new
      live "/history/overview", TwitchLive.Histories.Request, :overview
      live "/history/channels", TwitchLive.Histories.Request, :channels
      live "/history/messages", TwitchLive.Histories.Messages, :index

      live "/games/eurovision", GamesLive.Eurovision.Homepage, :index
      live "/games/eurovision/new", GamesLive.Eurovision.Homepage, :new
      live "/games/eurovision/ceremony/:id", GamesLive.Eurovision.Ceremony, :index
      live "/games/eurovision/ceremony/:id/vote", GamesLive.Eurovision.Vote, :index
      live "/games/eurovision/ceremony/:id/leaderboard", GamesLive.Eurovision.Leaderboard, :index
    end
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]

    live_session :require_admin_user,
      on_mount: [{TwitchStoryWeb.UserAuth, :ensure_authenticated}] do
      live "/admin/dashboard", AdminLive.Dashboard, :index
      live "/admin/users", AdminLive.Users, :index
      live "/admin/users/:id", AdminLive.Users, :show_user
      live "/admin/users/:id/edit", AdminLive.Users, :edit_user
      live "/admin/events", AdminLive.Events, :index
      live "/admin/flags", AdminLive.FeatureFlags, :index
      live "/admin/flags/:name/users", AdminLive.FeatureFlags, :users
      live "/admin/channels", AdminLive.Channels, :index
      live "/admin/channels/clips", AdminLive.Channels.Clips, :index
      live "/admin/channels/schedules", AdminLive.Channels.Schedules, :index
      live "/admin/channels/schedules/:id", AdminLive.Channels.Schedules, :show
      live "/admin/oauth", AdminLive.Oauth, :index
    end
  end

  scope "/", TwitchStoryWeb do
    pipe_through [:browser]

    get "/about", PageController, :about
    get "/images/eurovision/:code", ImageController, :eurovision
    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TwitchStoryWeb.UserAuth, :mount_current_user}] do
      live "/", HomepageLive, :index

      live "/users/confirm/:token", AccountsLive.ConfirmationLive, :edit
      live "/users/confirm", AccountsLive.ConfirmationInstructionsLive, :new
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
      forward "/flags", FunWithFlags.UI.Router
    end
  end
end
