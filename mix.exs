defmodule TwitchStory.MixProject do
  @moduledoc false

  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :twitch_story,
      version: @version,
      elixir: "~> 1.17",
      consolidate_protocols: Mix.env() != :test,
      elixirc_options: [warnings_as_errors: true],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      compilers: [] ++ Mix.compilers(),
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      test_coverage: [tool: ExCoveralls],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      releases: [
        twitch_story: [
          applications: [
            twitch_story: :permanent,
            opentelemetry_exporter: :permanent,
            opentelemetry: :temporary
          ]
        ]
      ]
    ]
  end

  def cli do
    [
      preferred_envs: ["test.unit": :test, "test.integration": :test]
    ]
  end

  def application do
    [
      mod: {TwitchStory.Application, []},
      extra_applications: [:postgrex, :logger, :runtime_tools, :os_mon, :set_locale]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Web
      {:phoenix, "~> 1.7.10"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_live_dashboard, "~> 0.8.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_ecto, "~> 4.4"},
      {:floki, "~> 0.36", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.20"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, ">= 0.0.0"},
      {:bcrypt_elixir, "~> 3.0"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_twitch, "~> 0.2"},
      {:set_locale, "~> 0.2.1"},
      {:fun_with_flags_ui, "~> 1.0"},
      # Mobile
      {:live_view_native,
       git: "https://github.com/liveview-native/live_view_native", branch: "main", override: true},
      {:live_view_native_stylesheet,
       git: "https://github.com/liveview-native/live_view_native_stylesheet", branch: "main"},
      {:live_view_native_swiftui,
       git: "https://github.com/liveview-native/liveview-client-swiftui", branch: "main"},
      {:live_view_native_live_form,
       git: "https://github.com/liveview-native/liveview-native-live-form", branch: "main"},
      # Backend
      {:uniq, "~> 0.1"},
      {:uuid, "~> 1.1"},
      {:req, "~> 0.5"},
      {:timex, "~> 3.7"},
      {:jason, "~> 1.2"},
      {:poison, "~> 6.0"},
      {:sweet_xml, "~> 0.7"},
      {:websockex, "~> 0.4"},
      {:oban, "~> 2.18"},
      {:explorer, "~> 0.9"},
      {:vega_lite, "~> 0.1"},
      {:swoosh, "~> 1.17"},
      {:postgrex, "~> 0.19"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, "~> 0.17"},
      {:scrivener_ecto, "~> 3.0"},
      {:eventstore, "~> 1.4"},
      {:hackney, "~> 1.19"},
      {:ex_aws, "~> 2.5"},
      {:ex_aws_s3, "~> 2.5"},
      {:fun_with_flags, "~> 1.12"},
      # Monitoring
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:opentelemetry_exporter, "~> 1.0"},
      {:opentelemetry, "~> 1.0"},
      {:opentelemetry_api, "~> 1.0"},
      {:opentelemetry_ecto, "~> 1.0"},
      {:opentelemetry_liveview, "~> 1.0.0-rc.4"},
      {:opentelemetry_oban, "~> 0.2.0-rc.5"},
      {:opentelemetry_phoenix, "~> 1.0"},
      {:opentelemetry_sentry, "~> 0.1.0"},
      {:sentry, "~> 10.0"},
      # Development tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      # Installation
      env: [cmd("export $(cat .env)")],
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "event_store.create", "event_store.init"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seed": ["ecto.setup", "run priv/repo/seeds.exs"],
      translate: [
        "gettext.extract",
        "gettext.merge priv/gettext --locale en",
        "gettext.merge priv/gettext --locale fr"
      ],
      # Development
      quality: ["format", "credo --strict", "sobelow --config", "dialyzer"],
      test: ["ecto.setup", "test"],
      "test.unit": [cmd("docker compose up -d"), "ecto.setup", "coveralls.html"],
      "test.integration": ["test --only api, data, s3"],
      start: ["env", cmd("docker compose up -d"), "ecto.setup", "phx.server"],
      # Deployment
      "deploy.local": [cmd("docker compose up --profile prod up --build")],
      "deploy.prod": [cmd("fly deploy")]
    ]
  end

  # Run a shell command
  defp cmd(command), do: fn _ -> Mix.shell().cmd(command) end
end
