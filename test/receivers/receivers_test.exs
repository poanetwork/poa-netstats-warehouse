defmodule Receivers.ReceiversTest do
  use ExUnit.Case

  test "__using__ Receiver" do
    defmodule Receiver1 do
      use POABackend.Receiver

      def init_receiver(_args) do
        {:ok, :no_state}
      end

      def metrics_received(_metric, _from, state) do
        {:ok, state}
      end

      def terminate(_state) do
        :ok
      end
    end

    state = %{name: :receiver, args: [], subscribe_to: []}

    assert Receiver1.init(state) == {:consumer, %{internal_state: :no_state, name: :receiver, args: [], subscribe_to: []}, [subscribe_to: []]}
  end

  test "integration between metric and receiver" do
    defmodule Receiver2 do
      use POABackend.Receiver

      def init_receiver(state) do
        {:ok, state}
      end

      def metrics_received(metrics, _from, state) do
        for metric <- metrics do
          send(state[:test_pid], {:metric_received, metric})
        end

        {:ok, state}
      end

      def terminate(_state) do
        :ok
      end
    end

    state = %{name: :receiver, args: [test_pid: self()], subscribe_to: [:ethereum_metrics]}

    {:ok, _} = Receiver2.start_link(state)

    POABackend.Metric.add(:ethereum_metrics, [:message1, :message2])
    POABackend.Metric.add(:ethereum_metrics, :message3)

    metrics_pid = Process.whereis(:ethereum_metrics)

    send(metrics_pid, :nothing_happens)

    assert_receive {:metric_received, :message1}, 20_000
    assert_receive {:metric_received, :message2}, 20_000
    assert_receive {:metric_received, :message3}, 20_000
  end
end