defmodule PhoenixShield.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_shield,
      version: "1.0.0-alpha",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      # ExDoc configuration
      name: "PhoenixShield",
      description: "A powerful Role-Based Access Control (RBAC) library for Phoenix Framework",
      package: package(),
      source_url: "https://github.com/yourusername/phoenix_shield",
      homepage_url: "https://github.com/yourusername/phoenix_shield",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Your Name"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/yourusername/phoenix_shield"}
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Core dependencies for the RBAC package
      {:phoenix, "~> 1.8.5", runtime: false},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0", optional: true},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:jason, "~> 1.2"},
      # Example app dependencies (only for development/test)
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8.3", only: :dev},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev, only: :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev, only: :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1,
       only: :dev},
      {:swoosh, "~> 1.16", only: :dev},
      {:req, "~> 0.5", only: :dev},
      {:telemetry_metrics, "~> 1.0", only: :dev},
      {:telemetry_poller, "~> 1.0", only: :dev},
      {:gettext, "~> 1.0", only: :dev},
      {:dns_cluster, "~> 0.2.0", only: :dev},
      {:bandit, "~> 1.5", only: :dev},
      {:lazy_html, ">= 0.1.0", only: :test},
      # Documentation dependencies
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["test"],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
