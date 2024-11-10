import Config

if System.get_env("PHX_SERVER") do
  config :twitch_story, TwitchStoryWeb.Endpoint, server: true
end

if config_env() == :prod do
  # Twitch Story --------------------------------------------------------------------------

  config :twitch_story, files: System.fetch_env!("FILES_PATH")

  postgres = [
    database: System.get_env("POSTGRES_DATABASE", "twitch_story_dev"),
    username: System.get_env("POSTGRES_USERNAME", "postgres"),
    password: System.get_env("POSTGRES_PASSWORD", "postgres"),
    hostname: System.get_env("POSTGRES_HOSTNAME", "localhost"),
    port: String.to_integer(System.get_env("DB_PORT", "5432")),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5"))
  ]

  config :twitch_story, TwitchStory.Repo, postgres
  config :twitch_story, TwitchStory.EventStore, postgres

  # Twitch Story Web ----------------------------------------------------------------------

  config :twitch_story, :dns_cluster_query, System.fetch_env!("DNS_CLUSTER_QUERY")

  config :twitch_story, TwitchStoryWeb.Endpoint,
    url: [host: System.get_env("PHX_HOST", "example.com"), port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT", "4000"))
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE") || raise("SECRET_KEY_BASE missing")

  # Mobile --------------------------------------------------------------------------------
  # Job processing ------------------------------------------------------------------------
  # Authentification ----------------------------------------------------------------------

  config :ueberauth, Ueberauth.Strategy.Twitch.OAuth,
    client_id: System.fetch_env!("TWITCH_CLIENT_ID"),
    client_secret: System.fetch_env!("TWITCH_CLIENT_SECRET"),
    redirect_uri: System.fetch_env!("TWITCH_REDIRECT_URI")

  # Observability -------------------------------------------------------------------------

  config :opentelemetry_exporter,
    otlp_protocol: :http_protobuf,
    otlp_endpoint: "https://api.honeycomb.io:443",
    otlp_headers: [
      {"x-honeycomb-team", System.get_env("HONEYCOMB_API_KEY")},
      {"x-honeycomb-dataset", "twitch-story"}
    ]

  config :sentry,
    dsn: System.fetch_env!("SENTRY_DSN")

  # ---------------------------------------------------------------------------------------
end
