import Config

config :twitch_story, TwitchStory.Repo,
  database: Path.expand("../twitch_story_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :twitch_story, TwitchStoryWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
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
      ~r"lib/twitch_story_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :twitch_story, TwitchStory.Notifications.Mailer,
  adapter: Swoosh.Adapters.Local

config :twitch_story, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view, :debug_heex_annotations, true
