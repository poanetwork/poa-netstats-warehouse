defmodule POABackend.Metrics.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    # create the children from the config file
    metrics = Application.get_env(:poa_backend, :metrics)

    children = for metric <- metrics do
      worker(POABackend.Metric, [metric])
    end

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
  
end