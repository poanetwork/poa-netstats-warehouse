defmodule POABackend.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :poa_backend,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug],
      mod: {POABackend.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},

      # Tests
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.8", only: [:test, :dev], runtime: false},

      # Docs
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "POABackend",
      source_url: "https://github.com/poanetwork/poa-netstats-wharehouse",
      groups_for_modules: [
        "POA Protocol": [
          POABackend.Protocol,
          POABackend.Protocol.Message,
          POABackend.Protocol.MessageType,
          POABackend.Protocol.DataType
        ]
      ]
    ]
  end

  defp aliases do
    [docs: ["docs", &picture/1]]
  end

  defp picture(_) do
    File.cp("./assets/backend_architecture.png", "./doc/backend_architecture.png")
  end
end
