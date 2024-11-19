import Config

# Twitch Story --------------------------------------------------------------------------

config :twitch_story,
  file_storage: TwitchStory.FileStorage.Filesystem

config :twitch_story, :twitch_api,
  id_api_url: "https://id.twitch.tv",
  api_url: "https://api.twitch.tv",
  client_id: System.get_env("TWITCH_CLIENT_ID"),
  client_secret: System.get_env("TWITCH_CLIENT_SECRET")

config :twitch_story, :games,
  eurovision: [
    apis: [flags: TwitchStory.Games.Eurovision.Country.Apis.FlagsApi]
  ]

postgres = [
  database: "twitch_story_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true
]

config :twitch_story, TwitchStory.Repo, postgres
config :twitch_story, TwitchStory.EventStore, postgres

config :twitch_story, TwitchStory.Notifications.Mailer, adapter: Swoosh.Adapters.Local

# Twitch Story Web ----------------------------------------------------------------------

config :twitch_story, TwitchStoryWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "MAi7StRhSnahdbbbfK3634M50g+Fk0EEISUgLzw9K7CQanvx6B97QNFrCk63sDhB",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :twitch_story, TwitchStoryWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/twitch_story_web/(controllers|live|components)/.*(ex|heex)$",
      ~r"lib/twitch_story_web/(live|components)/.*neex$",
      ~r"lib/twitch_story_web/styles/*.ex$",
      ~r"priv/static/*.styles$"
    ]
  ]

config :twitch_story, dev_routes: true
config :phoenix, stacktrace_depth: 20, plug_init_mode: :runtime
config :phoenix_live_view, :debug_heex_annotations, true

# Mobile --------------------------------------------------------------------------------

config :live_view_native_stylesheet, annotations: true, pretty: true

# Job processing ------------------------------------------------------------------------
# Authentification ----------------------------------------------------------------------

config :ueberauth, Ueberauth.Strategy.Twitch.OAuth,
  client_id: System.get_env("TWITCH_CLIENT_ID"),
  client_secret: System.get_env("TWITCH_CLIENT_SECRET"),
  redirect_uri: System.get_env("TWITCH_REDIRECT_URI")

# Observability -------------------------------------------------------------------------

if System.get_env("DEBUG_OTEL") == "true" do
  config :opentelemetry, :processors,
    otel_batch_processor: %{exporter: {:otel_exporter_stdout, []}}
else
  config :opentelemetry, traces_exporter: :none
end

config :logger, :console, format: "[$level] $message\n"

# ---------------------------------------------------------------------------------------
