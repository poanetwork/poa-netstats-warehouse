defmodule POABackend.Receivers.System.Stats do
  use POABackend.Receiver

  @moduledoc false

  alias POABackend.Protocol.Message
  alias POABackend.Receivers.Models.SystemStats
  alias POABackend.Receivers.Repo

  def init_receiver(_args) do
    {:ok, :no_state}
  end

  def metrics_received([%Message{agent_id: agent_id, data: %{"type" => "statistics", "body" => stats}}], _from, state) do
    :ok = save_data(stats, agent_id)
    {:ok, state}
  end
  def metrics_received(_metrics, _from, state) do
    {:ok, state}
  end

  def handle_message(_message, state) do
    {:ok, state}
  end

  def handle_inactive(_agent_id, state) do
    {:ok, state}
  end

  def terminate(_state) do
    :ok
  end

  defp save_data(%{"cpu_load" => cpu_load, "disk_usage" => disk_usage, "memory_usage" => memory_usage}, agent_id) do

    SystemStats.new()
    |> SystemStats.date(NaiveDateTime.utc_now())
    |> SystemStats.agent_id(agent_id)
    |> SystemStats.cpu_load(cpu_load)
    |> SystemStats.disk_usage(disk_usage)
    |> SystemStats.memory_usage(memory_usage)
    |> Repo.insert()

    :ok
  end
  defp save_data(_data, _agent_id) do
    :ok
  end

end
