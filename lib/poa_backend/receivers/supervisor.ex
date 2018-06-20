defmodule POABackend.Receivers.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    receivers = Application.get_env(:poa_backend, :receivers)
    subscriptions = Application.get_env(:poa_backend, :subscriptions)

    children = for {name, module, args} <- receivers do
      worker(module, [%{name: name, subscribe_to: subscriptions[name], args: args}])
    end

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
  
end