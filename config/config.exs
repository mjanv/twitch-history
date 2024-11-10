import Config

# Twitch Story --------------------------------------------------------------------------

config :twitch_story,
  ecto_repos: [TwitchStory.Repo],
  event_stores: [TwitchStory.EventStore],
  generators: [timestamp_type: :utc_datetime],
  event_bus: [
    TwitchStory.Notifications.PubSub,
    TwitchStory.Notifications.Log,
    TwitchStory.EventStore
  ],
  sentry: "https://maxime-janvier.sentry.io/projects",
  s3: "https://console.tigris.dev/flyio_6x3wkn12kqwmqvop/buckets"

config :twitch_story, :feature_flags,
  games: [
    eurovision: true
  ]

config :twitch_story, TwitchStory.Repo, migration_primary_key: [type: :uuid]

config :twitch_story, TwitchStory.EventStore,
  serializer: EventStore.JsonSerializer,
  schema: "events"

config :twitch_story, TwitchStory.Notifications.Mailer, adapter: Swoosh.Adapters.Local

config :ex_aws,
  debug_requests: true,
  json_codec: Jason,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

config :ex_aws, :s3, scheme: "https://", host: "fly.storage.tigris.dev", region: "auto"

config :fun_with_flags, :cache,
  enabled: true,
  # in seconds
  ttl: 900

config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: TwitchStory.Repo,
  ecto_table_name: "feature_flags",
  ecto_primary_key_type: :binary_id

config :fun_with_flags, :cache_bust_notifications,
  enabled: true,
  adapter: FunWithFlags.Notifications.PhoenixPubSub,
  client: TwitchStory.PubSub

# Twitch Story Web ----------------------------------------------------------------------

config :twitch_story, TwitchStoryWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TwitchStoryWeb.Errors.ErrorHTML, json: TwitchStoryWeb.Errors.ErrorJSON],
    layout: false
  ],
  pubsub_server: TwitchStory.PubSub,
  live_view: [signing_salt: "c73B9kuB"]

config :twitch_story, TwitchStoryWeb.Gettext,
  locales: ~w(en fr),
  default_locale: "en"

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :phoenix, :json_library, Jason

# Mobile --------------------------------------------------------------------------------

config :phoenix_template, :format_encoders, swiftui: Phoenix.HTML.Engine
config :mime, :types, %{"text/styles" => ["styles"], "text/swiftui" => ["swiftui"]}
config :live_view_native, plugins: [LiveViewNative.SwiftUI]
config :phoenix, :template_engines, neex: LiveViewNative.Engine

config :live_view_native_stylesheet,
  content: [swiftui: ["lib/**/swiftui/*", "lib/**/*swiftui*"]],
  output: "priv/static/assets"

# Job processing ------------------------------------------------------------------------

crontab = [
  # Oauth token renewal at boot and every 15 minutes for token expiring in 30 minutes
  {"*/15 * * * *", TwitchStory.Twitch.Workers.OauthWorker, args: %{n: 30 * 60}},
  # Clips retrieval for all channels every 30 minutes for clips created in the last hour
  {"*/30 * * * *", TwitchStory.Twitch.Workers.Channels.ClipsWorker,
   args: %{step: "start", hour: -1}},
  # Schedule retrieval for all channels every hour
  {"0 */1 * * *", TwitchStory.Twitch.Workers.Channels.ScheduleWorker, args: %{step: "start"}},
  # Etl extraction of countries
  {"@reboot", TwitchStory.Games.Eurovision.Country.Workers.Etl, args: %{}}
]

config :twitch_story, Oban,
  engine: Oban.Engines.Basic,
  repo: TwitchStory.Repo,
  plugins: [
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(30)},
    {Oban.Plugins.Pruner, max_age: 60},
    {Oban.Plugins.Cron, crontab: crontab}
  ],
  queues: [twitch: 10, api: 10]

# Authentification ----------------------------------------------------------------------

config :ueberauth, Ueberauth,
  providers: [
    twitch: {
      Ueberauth.Strategy.Twitch,
      [
        default_scope: "user:read:email user:read:follows user:read:subscriptions",
        ignores_csrf_attack: true
      ]
    }
  ]

# Observability -------------------------------------------------------------------------

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sentry,
  environment_name: config_env(),
  enable_source_code_context: true,
  root_source_code_paths: [File.cwd!()],
  integrations: [
    oban: [
      capture_errors: true,
      cron: [enabled: true]
    ]
  ]

# ---------------------------------------------------------------------------------------

import_config "#{config_env()}.exs"
