defmodule Receivers.DashboardTest do
  use ExUnit.Case

  alias POABackend.Protocol.Message

  @base_url "http://localhost:8181"

  defmodule Client do
    use WebSockex

    def send(client, message, caller) do
      WebSockex.send_frame(client, {:text, message})
      Kernel.send(caller, :message_sent)
    end

    def start_link(address, state, opts \\ []) do
      WebSockex.start_link(address, __MODULE__, state, opts)
    end

    def handle_frame({_type, msg}, caller) do
      Kernel.send(caller, msg)

      {:ok, caller}
    end
  end

  test "wrong wssecret" do
    assert {:error, %WebSockex.RequestError{code: 400, message: "Bad Request"}} == Client.start_link("http://localhost:8181/ws", :state, [{:extra_headers, [{"wssecret", "wrongsecret"}]}])
    assert {:error, %WebSockex.RequestError{code: 400, message: "Bad Request"}} == Client.start_link("http://localhost:8181/ws", :state)
  end

  test "connection success" do
    {result, pid} = Client.start_link("http://localhost:8181/ws", :state, [{:extra_headers, [{"wssecret", "mywssecret"}]}])

    assert :ok == result
    assert is_pid(pid)
  end

  test "ws receive metric" do
    Client.start_link("http://localhost:8181/ws", self(), [{:extra_headers, [{"wssecret", "mywssecret"}]}])

    POABackend.Metric.add(:ethereum_metrics, [message()])

    expected_message = expected_message()

    assert_receive ^expected_message, 20_000
  end

  test "When the Dashboard connects already exists last metrics in the Backend" do

    # we send the metrics twice in order to complete all the cases in the Receiver
    # when the ets doesn't have the agentid and when it already exists
    POABackend.Metric.add(:ethereum_metrics, [information_message(), stats_message(), information_message()])
    POABackend.Metric.add(:ethereum_metrics, [information_message2(), stats_message2()])

    Client.start_link("http://localhost:8181/ws", self(), [{:extra_headers, [{"wssecret", "mywssecret"}]}])

    expected_information_message = expected_information_message()
    expected_stats_message = expected_stats_message()
    expected_information_message2 = expected_information_message2()
    expected_stats_message2 = expected_stats_message2()

    assert_receive ^expected_information_message, 20_000
    assert_receive ^expected_stats_message, 20_000
    assert_receive ^expected_information_message2, 20_000
    assert_receive ^expected_stats_message2, 20_000
  end

  test "handle messages from the client to the server (test coverage)" do
    {:ok, client} = Client.start_link("http://localhost:8181/ws", self(), [{:extra_headers, [{"wssecret", "mywssecret"}]}])

    Client.send(client, "hello", self())

    assert_receive :message_sent, 20_000
  end

  test "http call to the server (test coverage)" do
    {:ok, response} = HTTPoison.post(@base_url <> "/someendpoint", "data", [])

    assert 404 == response.status_code
  end

  defp expected_message do
    "{\"data\":{\"c\":\"c\",\"b\":\"b\",\"a\":\"a\"},\"agent_id\":\"agentid1\"}"
  end

  defp message do
    Message.new("agentid1", :ethereum_metric, :data, %{a: "a", b: "b", c: "c"})
  end

  defp information_message do
    Message.new("agentid", :ethereum_metric, :data, %{"type" => "information"})
  end

  defp stats_message do
    Message.new("agentid", :ethereum_metric, :data, %{"type" => "statistics"})
  end

  defp information_message2 do
    Message.new("agentid2", :ethereum_metric, :data, %{"type" => "information"})
  end

  defp stats_message2 do
    Message.new("agentid2", :ethereum_metric, :data, %{"type" => "statistics"})
  end

  defp expected_information_message do
    "{\"data\":{\"type\":\"information\"},\"agent_id\":\"agentid\"}"
  end

  defp expected_stats_message do
    "{\"data\":{\"type\":\"statistics\"},\"agent_id\":\"agentid\"}"
  end

  defp expected_information_message2 do
    "{\"data\":{\"type\":\"information\"},\"agent_id\":\"agentid2\"}"
  end

  defp expected_stats_message2 do
    "{\"data\":{\"type\":\"statistics\"},\"agent_id\":\"agentid2\"}"
  end
end