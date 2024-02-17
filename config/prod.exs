import Config

config :twitch_story, TwitchStoryWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :swoosh, local: false

config :logger, level: :info
