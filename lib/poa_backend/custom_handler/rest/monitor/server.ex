defmodule POABackend.CustomHandler.REST.Monitor.Server do
  @moduledoc false

  use GenServer

  @timeout 7000
  @registry :rest_activity_monitor_registry

  def start_link(args) do
    agent_id = via_tuple(args)
    GenServer.start_link(__MODULE__, args, name: agent_id)
  end

  def child_spec do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :temporary,
      shutdown: 500
    }
  end

  def init(args) do
    {:ok, %{agent_id: args}, @timeout}
  end

  def handle_cast(:ping, state) do
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  def terminate(_, state) do
    set_inactive(state.agent_id)
    Registry.unregister(@registry, state.agent_id)
  end

  defp via_tuple(agent_id) do
    {:via, Registry, {@registry, agent_id}}
  end

  defp set_inactive(agent_id) do
    POABackend.CustomHandler.publish_inactive(agent_id)
  end
end