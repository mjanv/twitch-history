import Config

# Twitch Story --------------------------------------------------------------------------

config :twitch_story,
  event_bus: [TwitchStory.EventStore]

config :twitch_story, :games,
  eurovision: [
    apis: [flags: TwitchStory.Games.Eurovision.Country.Apis.FlagPrivApi]
  ]

postgres = [
  database: "twitch_story_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox
]

config :twitch_story, TwitchStory.Repo, postgres
config :twitch_story, TwitchStory.EventStore, postgres

config :twitch_story, TwitchStory.Notifications.Mailer, adapter: Swoosh.Adapters.Test

config :ex_aws,
  debug_requests: true,
  json_codec: Jason,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

# Twitch Story Web ----------------------------------------------------------------------

config :twitch_story, TwitchStoryWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "oLeeZY7mwEAOCZU+FRLXoJ/Y0mVQZ3LWIhgX3T93AoiQvPctXJIHlFoFrOLMnivg",
  server: false

config :bcrypt_elixir, :log_rounds, 1
config :phoenix, :plug_init_mode, :runtime

# Mobile --------------------------------------------------------------------------------
# Job processing ------------------------------------------------------------------------

config :twitch_story, Oban, testing: :inline

# Authentification ----------------------------------------------------------------------
# Observability -------------------------------------------------------------------------

config :opentelemetry, traces_exporter: :none

config :logger, level: :warning

# ---------------------------------------------------------------------------------------
