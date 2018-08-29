defmodule POABackend.Receivers.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    receivers = Application.get_env(:poa_backend, :receivers)
    subscriptions = Application.get_env(:poa_backend, :subscriptions)

    # getting the children from the config file
    children = for {name, module, args} <- receivers do
      worker(module, [%{name: name, subscribe_to: subscriptions[name], args: args}])
    end

    # we have to add the Repo to the children too
    children = [supervisor(POABackend.Receivers.Repo, []) | children]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
  
end