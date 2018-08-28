defmodule POABackend.Receivers.EthStats do
  use POABackend.Receiver

  @moduledoc false

  alias POABackend.Protocol.Message
  alias POABackend.Receivers.Models.EthStats
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

  defp save_data(%{"active" => active, "gasPrice" => gas_price, "hashrate" => hashrate, "mining" => mining, "peers" => peers, "syncing" => syncing}, agent_id) do
    current_block = current_block(syncing)
    highest_block = highest_block(syncing)
    starting_block = starting_block(syncing)
    
    EthStats.new()
    |> EthStats.date(NaiveDateTime.utc_now())
    |> EthStats.agent_id(agent_id)
    |> EthStats.active(active)
    |> EthStats.mining(mining)
    |> EthStats.hashrate(hashrate)
    |> EthStats.peers(peers)
    |> EthStats.gas_price(gas_price)
    |> EthStats.current_block(current_block)
    |> EthStats.highest_block(highest_block)
    |> EthStats.starting_block(starting_block)
    |> Repo.insert()

    :ok
  end
  defp save_data(_data, _agent_id) do
    :ok
  end

  defp current_block(syncing) do
    get_from_sync(syncing, "currentBlock")
  end

  defp highest_block(syncing) do
    get_from_sync(syncing, "highestBlock")
  end

  defp starting_block(syncing) do
    get_from_sync(syncing, "startingBlock")
  end

  defp get_from_sync(syncing, key) when is_map(syncing) do
    Map.get(syncing, key)
  end
  defp get_from_sync(_, _) do
    nil
  end
end
