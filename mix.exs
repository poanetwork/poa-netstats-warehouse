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
      extra_applications: [:logger, :cowboy, :plug, :poison, :worker_pool],
      mod: {POABackend.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:gen_stage, "~> 0.14"},
      {:worker_pool, "~> 3.1"},
      {:ex_aws_dynamo, "~> 2.0"},
      {:hackney, "~> 1.12"},

      # Tests
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.8", only: [:test, :dev], runtime: false},
      {:httpoison, "~> 1.0", only: [:test], runtime: true},
      {:mock, "~> 0.3", only: [:test], runtime: false},
      {:websockex, "~> 0.4", only: [:test]},

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
        ],
        "Custom Handler": [
          POABackend.CustomHandler,
          POABackend.CustomHandler.REST
        ],
        "Receivers": [
          POABackend.Receiver,
          POABackend.Receivers.DynamoDB,
          POABackend.Receivers.Dashboard
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
