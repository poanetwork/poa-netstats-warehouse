defmodule Receivers.DashboardTest do
  use ExUnit.Case

  alias POABackend.Protocol.Message

  @base_url "http://localhost:8181"

  defmodule Client do
    use WebSockex

    def send(client, message) do
      WebSockex.send_frame(client, {:text, message})
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

  test "handle messages from the client to the server (test coverage)" do
    {:ok, client} = Client.start_link("http://localhost:8181/ws", self(), [{:extra_headers, [{"wssecret", "mywssecret"}]}])

    Client.send(client, "hello")
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

end