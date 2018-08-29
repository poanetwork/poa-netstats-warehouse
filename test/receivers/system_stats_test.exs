defmodule Receivers.SystemStatsTest do
  use ExUnit.Case

  alias POABackend.Protocol.Message
  alias POABackend.Ancillary.Utils
  alias POABackend.Receivers.Repo
  alias POABackend.Receivers.Models.SystemStats

  setup do
    Utils.clear_db()

    on_exit fn ->
      Utils.clear_db()
    end

    []
  end

  test "storing stats" do
    assert [] == Repo.all(SystemStats)

    POABackend.Metric.add(:system_metrics, [raw_stats()])

    # this will create an entry in the DB
    Process.sleep(5000)

    [stats] = Repo.all(SystemStats)

    assert "agent_id1" == stats.agent_id
    assert 9.1234 == stats.cpu_load
    assert 75 == stats.disk_usage
    assert 10.1234 == stats.memory_usage
  end

  defp raw_stats do
    stats = %{
      "cpu_load" => 9.1234,
      "disk_usage" => 75,
      "memory_usage" => 10.1234
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