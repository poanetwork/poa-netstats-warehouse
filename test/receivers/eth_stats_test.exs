defmodule Receivers.EthStatsTest do
  use ExUnit.Case

  alias POABackend.Protocol.Message
  alias POABackend.Ancillary.Utils
  alias POABackend.Receivers.Repo
  alias POABackend.Receivers.Models.EthStats

  setup do
    Utils.clear_db()

    on_exit fn ->
      Utils.clear_db()
    end

    []
  end

  test "storing stats" do
    assert [] == Repo.all(EthStats)

    POABackend.Metric.add(:ethereum_metrics, [raw_stats()])

    # this will create an entry in the DB
    Process.sleep(5000)

    [stats] = Repo.all(EthStats)

    assert "agent_id1" == stats.agent_id
    assert false == stats.mining
    assert 0 == stats.hashrate
    assert 3 == stats.peers
    assert 0 == stats.gas_price
    assert "0x44ee0" == stats.current_block
    assert "0x44ee2" == stats.highest_block
    assert "0x40ad3" == stats.starting_block
  end

  defp raw_stats do
    stats = %{
      "active" => true,
      "gasPrice" => 0,
      "hashrate" => 0,
      "mining" => false,
      "peers" => 3,
      "syncing" => %{
        "currentBlock" => "0x44ee0",
        "highestBlock" => "0x44ee2",
        "startingBlock" => "0x40ad3"
      }
    }

    %Message{
      agent_id: "agent_id1",
      data: %{
        "type" => "statistics",
        "body" => stats
        }
      }
  end

end