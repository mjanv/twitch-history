import Config

config :twitch_story, TwitchStory.Repo,
  database: Path.expand("../twitch_story_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

config :twitch_story, TwitchStoryWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "oLeeZY7mwEAOCZU+FRLXoJ/Y0mVQZ3LWIhgX3T93AoiQvPctXJIHlFoFrOLMnivg",
  server: false

config :twitch_story, Oban, testing: :inline

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
