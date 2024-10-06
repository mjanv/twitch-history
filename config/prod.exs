import Config

config :twitch_story, :feature_flags,
  games: [
    eurovision: false
  ]

config :twitch_story,
  event_bus: [TwitchStory.EventStore]

config :twitch_story, :games,
  eurovision: [
    apis: [flags: TwitchStory.Games.Eurovision.Country.Apis.FlagsApi]
  ]

config :twitch_story, TwitchStoryWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :swoosh, local: false

config :logger, level: :info
