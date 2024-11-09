import Config

if System.get_env("PHX_SERVER") do
  config :twitch_story, TwitchStoryWeb.Endpoint, server: true
end

if config_env() == :prod do
  config :twitch_story,
    files: System.fetch_env!("FILES_PATH") || raise("FILES_PATH missing.")

  config :twitch_story, :twitch_api,
    client_id: System.fetch_env!("TWITCH_CLIENT_ID"),
    client_secret: System.fetch_env!("TWITCH_CLIENT_SECRET")

  config :ueberauth, Ueberauth.Strategy.Twitch.OAuth,
    client_id: System.fetch_env!("TWITCH_CLIENT_ID"),
    client_secret: System.fetch_env!("TWITCH_CLIENT_SECRET"),
    redirect_uri: System.fetch_env!("TWITCH_REDIRECT_URI")

  config :twitch_story, TwitchStory.Repo,
    database: System.get_env("POSTGRES_DATABASE", "twitch_story_dev"),
    username: System.get_env("POSTGRES_USERNAME", "postgres"),
    password: System.get_env("POSTGRES_PASSWORD", "postgres"),
    hostname: System.get_env("POSTGRES_HOSTNAME", "localhost"),
    port: String.to_integer(System.get_env("DB_PORT", "5432")),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5"))

  config :twitch_story, TwitchStory.EventStore,
    database: System.get_env("POSTGRES_DATABASE", "twitch_story_dev"),
    username: System.get_env("POSTGRES_USERNAME", "postgres"),
    password: System.get_env("POSTGRES_PASSWORD", "postgres"),
    hostname: System.get_env("POSTGRES_HOSTNAME", "localhost"),
    port: String.to_integer(System.get_env("DB_PORT", "5432")),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "5"))

  config :twitch_story, :dns_cluster_query, System.fetch_env!("DNS_CLUSTER_QUERY")

  config :twitch_story, TwitchStoryWeb.Endpoint,
    url: [host: System.get_env("PHX_HOST", "example.com"), port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT", "4000"))
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE") || raise("SECRET_KEY_BASE missing")

  config :sentry,
    dsn: System.fetch_env!("SENTRY_DSN")

  config :ex_aws,
    debug_requests: true,
    json_codec: Jason,
    access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
    secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

  config :ex_aws, :s3,
    scheme: "https://",
    host: "fly.storage.tigris.dev",
    region: "auto"
end
