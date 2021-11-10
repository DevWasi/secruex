defmodule SecureX.MixProject do
  use Mix.Project

  def project do
    [
      app: :securex,
      version: "0.1.0",
      elixir: "~> 1.13",
      maintainers: ["Wasi."],
      licenses: ["Apache 2.0"],
      description: "SecureX Implementation.",
      links: %{"GitHub" => "https://github.com/DevWasi/secruex"},
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      aliases: aliases(),
      deps: deps(),
      name: "SecureX",
      source_url: "https://github.com/DevWasi/secruex",
      homepage_url: "https://github.com/DevWasi/secruex",
      docs: [
        main: "SecureX", # The main page in the docs
        extras: ["README.md"],
        api_reference: false
      ]
    ]
  end

  defp description do
    """
    SecureX Implementation.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Wasi."],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/DevWasi/secruex"},
      description: "SecureX Implementation."
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SecureX.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.7"},
      {:ecto, "~> 3.7"},
      {:cowboy, "~> 2.9", override: true},
      {:plug_cowboy, "~> 2.5"},
      {:phoenix, "~> 1.6"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.18.2"}
    ]
  end
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
