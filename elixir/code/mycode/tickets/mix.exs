defmodule Tickets.MixProject do
  use Mix.Project

  def project do
    [
      app: :tickets,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # applications: [:lager],
      extra_applications: [:lager, :logger],
      mod: {Tickets.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:broadway, "~> 1.1.0"},
      {:broadway_rabbitmq, "~> 0.7.0"},
      {:rabbit_common, "~> 3.13.4", override: true},
      {:lager, "~> 3.2"},
      {:amqp, "~> 3.3"}
    ]
  end
end
