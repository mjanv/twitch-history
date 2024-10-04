import Config

config :twitch_story, :games,
  eurovision: [
    apis: [flags: TwitchStory.Games.Eurovision.Country.Apis.FlagsApi]
  ]

config :twitch_story, TwitchStory.Repo,
  database: "twitch_story_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :twitch_story, TwitchStory.EventStore,
  database: "twitch_story_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool_size: 5

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

config :twitch_story, TwitchStory.Notifications.Mailer, adapter: Swoosh.Adapters.Local

config :twitch_story, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view, :debug_heex_annotations, true

# Mobile
config :live_view_native_stylesheet,
  annotations: true,
  pretty: true

config :mdns_lite,
  hosts: [:hostname, "twitch"],
  services: [%{id: :web_service, protocol: "http", transport: "tcp", port: 4000}]
