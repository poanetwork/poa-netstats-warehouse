defmodule POABackend.CustomHandler.REST.Monitor.Supervisor do
  @moduledoc false

  alias POABackend.CustomHandler.REST
  
  def start_link do
    Supervisor.start_link(__MODULE__, :noargs, name: __MODULE__)
  end

  def child_spec do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(:noargs) do
    children = [
      REST.Monitor.Server.child_spec()
    ]

    opts = [strategy: :simple_one_for_one]
    Supervisor.init(children, opts)
  end

end