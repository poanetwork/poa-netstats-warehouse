defmodule POABackend.CustomHandler.REST.Supervisor do
  @moduledoc false

  alias POABackend.CustomHandler.REST

  def start_link(rest_options) do
    Supervisor.start_link(__MODULE__, rest_options, name: __MODULE__)
  end

  def child_spec(rest_options) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [rest_options]},
      type: :supervisor,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(rest_options) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(scheme: rest_options[:scheme], plug: REST.Router, options: [port: rest_options[:port]]),
      supervisor(Registry, [:unique, :rest_activity_monitor_registry]),
      REST.Monitor.Supervisor.child_spec()
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
  
end