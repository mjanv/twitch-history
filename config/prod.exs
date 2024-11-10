import Config

# Twitch Story --------------------------------------------------------------------------

config :twitch_story,
  event_bus: [TwitchStory.EventStore]

config :twitch_story, :twitch_api,
  id_api_url: "https://id.twitch.tv",
  api_url: "https://api.twitch.tv",
  client_id: System.get_env("TWITCH_CLIENT_ID"),
  client_secret: System.get_env("TWITCH_CLIENT_SECRET")

config :twitch_story, :feature_flags,
  games: [
    eurovision: false
  ]

config :twitch_story, :games,
  eurovision: [
    apis: [flags: TwitchStory.Games.Eurovision.Country.Apis.FlagsApi]
  ]

config :swoosh, local: false

# Twitch Story Web ----------------------------------------------------------------------

config :twitch_story, TwitchStoryWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Mobile --------------------------------------------------------------------------------
# Job processing ------------------------------------------------------------------------
# Authentification ----------------------------------------------------------------------
# Observability -------------------------------------------------------------------------

config :opentelemetry, span_processor: :batch, exporter: :otlp

config :logger, level: :info

# ---------------------------------------------------------------------------------------
