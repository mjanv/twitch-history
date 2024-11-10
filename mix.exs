defmodule TwitchStory.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :twitch_story,
      version: "0.1.0",
      elixir: "~> 1.16",
      consolidate_protocols: Mix.env() != :test,
      elixirc_options: [warnings_as_errors: true],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      compilers: [] ++ Mix.compilers(),
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def cli do
    [
      default_task: "start",
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
      {:phoenix_ecto, "~> 4.4"},
      {:scrivener_ecto, "~> 3.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.2"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.20"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, ">= 0.0.0"},
      {:bcrypt_elixir, "~> 3.0"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_twitch, "~> 0.2"},
      {:set_locale, "~> 0.2.1"},
      # Mobile
      {:live_view_native, "~> 0.3.1"},
      {:live_view_native_stylesheet, "~> 0.3.1"},
      {:live_view_native_swiftui, "~> 0.3.1"},
      {:live_view_native_live_form, "~> 0.3.1"},
      # Backend
      {:uniq, "~> 0.1"},
      {:uuid, "~> 1.1"},
      {:req, "~> 0.5"},
      {:timex, "~> 3.7"},
      {:jason, "~> 1.2"},
      {:poison, "~> 3.0"},
      {:sweet_xml, "~> 0.6.6"},
      {:oban, "~> 2.18"},
      {:explorer, "~> 0.9"},
      {:vega_lite, "~> 0.1.8"},
      {:swoosh, "~> 1.17"},
      {:postgrex, "~> 0.19"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:eventstore, "~> 1.4"},
      {:hackney, "~> 1.19"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      # Monitoring
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:sentry, "~> 10.0"},
      # Development tools
      {:credo, "~> 1.7"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:mdns_lite, "~> 0.8.11", only: :dev}
    ]
  end

  defp aliases do
    [
      # Installation
      env: [fn _ -> Mix.shell().cmd("export $(cat .env)") end],
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
      # Local development
      quality: ["format", "credo --strict", "sobelow --config", "dialyzer"],
      test: ["ecto.setup", "test"],
      "test.unit": ["ecto.setup", "coveralls.html"],
      "test.integration": ["test --only api, data, s3"],
      start: ["ecto.setup", "phx.server"],
      # Deployment
      "deploy.build": [fn _ -> Mix.shell().cmd("docker build . -t twitch-story") end],
      deploy: [fn _ -> Mix.shell().cmd("fly deploy") end]
    ]
  end
end
