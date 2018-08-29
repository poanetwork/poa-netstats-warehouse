defmodule POABackend.Receivers.Eth.Stats do
  use POABackend.Receiver

  @moduledoc """
  This is a Receiver Plugin which is in charge of storing the Ethereum Statistics received from the Agents in a Postgres
  database. If we want to use it we have to declare it in the Config file, inside the `:receivers` section, ie:

      {:store_eth_stats, POABackend.Receivers.Eth.Stats, []}

  This Plugin uses Postgres as a backend, specifically the `eth_stats` table. Make sure that table exists before using 
  this Plugin.

  We also need to subscribe this plugin to `:ethereum_metrics` metrics in the config file. For that we have to add this line
  to the list in the `:subscriptions` section:

      {:store_eth_stats, [:ethereum_metrics]}
  """

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
