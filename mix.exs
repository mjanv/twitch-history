defmodule TwitchStory.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :twitch_story,
      version: "0.1.0",
      elixir: "~> 1.17",
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
      {:ecto_sql, "~> 3.10"},
      {:scrivener_ecto, "~> 3.0"},
      {:postgrex, "~> 0.19"},
      {:ecto_sqlite3, ">= 0.0.0"},
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
      {:oban, "~> 2.18"},
      {:explorer, "~> 0.9"},
      {:vega_lite, "~> 0.1.8"},
      {:swoosh, "~> 1.17"},
      {:eventstore, "~> 1.4"},
      # Monitoring
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      # Development tools
      {:credo, "~> 1.7"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:mdns_lite, "~> 0.8.11", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "event_store.create", "event_store.init"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seed": ["ecto.setup", "run priv/repo/seeds.exs"],
      quality: ["format", "credo --strict", "dialyzer"],
      test: ["ecto.setup", "test"],
      start: ["ecto.setup", "phx.server"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      env: [fn _ -> Mix.shell().cmd("export $(cat .env)") end],
      deploy: [fn _ -> Mix.shell().cmd("fly deploy") end],
      translate: [
        "gettext.extract",
        "gettext.merge priv/gettext --locale en",
        "gettext.merge priv/gettext --locale fr"
      ]
    ]
  end
end
