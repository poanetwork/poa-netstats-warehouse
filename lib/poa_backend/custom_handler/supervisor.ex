defmodule POABackend.CustomHandler.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    require Logger
    # create the children from the config file
    custom_handlers = Application.get_env(:poa_backend, :custom_handlers)

    children = for {name, module, options} <- custom_handlers do
      spec = apply(module, :child_spec, [options])
      
      Logger.info("Custom handler #{name} started.")

      spec
    end

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end