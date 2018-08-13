defmodule POABackend.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(POABackend.Auth.Repo, []),
      supervisor(POABackend.CustomHandler.Supervisor, []),
      supervisor(POABackend.Metrics.Supervisor, []),
      supervisor(POABackend.Receivers.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: POABackend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
