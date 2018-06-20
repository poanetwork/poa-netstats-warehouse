defmodule POABackend.Metric do

  @moduledoc false

  use GenStage

  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:producer, [], dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  # public endpoint for events adding
  def add(name, event), do: GenServer.cast(name, {:add, event})

  # just push events to consumers on adding
  def handle_cast({:add, events}, state) when is_list(events) do
    {:noreply, events, state}
  end
  def handle_cast({:add, events}, state), do: {:noreply, [events], state}

  # ignore any demand
  def handle_demand(_demand, state), do: {:noreply, [], state}
end