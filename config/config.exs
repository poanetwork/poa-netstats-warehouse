use Mix.Config

config :plug, :statuses, %{

  401 => "Unauthorized",
  415 => "Unsupported Media Type",
  422 => "Unprocessable Entity"
}

config :poa_backend,
  ecto_repos: [
    POABackend.Auth.Repo,
    POABackend.Receivers.Repo
  ]

# here we configure the needed data for Ecto and Mnesia (DB)
config :poa_backend, POABackend.Auth.Repo,
  priv: "priv/auth",
  adapter: EctoMnesia.Adapter,
  host: Kernel.node(),
  storage_type: :disc_copies # this will store the data on disk and memory

config :mnesia,
  dir: 'priv/data/mnesia' # make sure this directory exists!

import_config "#{Mix.env}.exs"
