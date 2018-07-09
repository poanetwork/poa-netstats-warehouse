defmodule CustomHandler.RESTTest do
  use ExUnit.Case

  alias POABackend.CustomHandler.REST.Monitor

  @base_url "localhost:4002"

  # ----------------------------------------
  # /ping Endpoint Tests
  # ----------------------------------------

  test "testing the REST /ping endpoint [JSON]" do
    {200, %{"result" => "success"}} = ping("agentID")
  end

  test "testing the REST /ping endpoint [MSGPACK]" do
    {200, %{"result" => "success"}} = ping("agentID")
  end

  test "testing the REST /ping endpoint without content-type" do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})

    {415, :nobody} = post(url, data, [])
  end

  test "testing the REST /ping endpoint without required fields" do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /ping endpoint with wrong secret" do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "wrong_secret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {401, :nobody} = post(url, data, headers)
  end

  test "POST /ping send inactive after stopping sending pings" do
    # first creating a Receiver in order to catch the inactive message

    defmodule Receiver1 do
      use POABackend.Receiver

      def init_receiver(state) do
        {:ok, state}
      end

      def metrics_received(_metrics, _from, state) do
        {:ok, state}
      end

      def handle_message(_message, state) do
        {:ok, state}
      end

      def handle_inactive(_, state) do
        send(state[:test_pid], :inactive_received)

        {:ok, state}
      end

      def terminate(_state) do
        :ok
      end
    end

    state = %{name: :receiver, args: [test_pid: self()], subscribe_to: [:ethereum_metrics]}

    {:ok, _} = Receiver1.start_link(state)

    %{active: active_monitors} = Supervisor.count_children(Monitor.Supervisor)

    agent_id = "NewAgentID"

    {200, %{"result" => "success"}} = ping(agent_id)

    active_monitors = active_monitors + 1

    %{active: ^active_monitors} = Supervisor.count_children(Monitor.Supervisor)

    {200, %{"result" => "success"}} = ping_msgpack(agent_id)

    %{active: ^active_monitors} = Supervisor.count_children(Monitor.Supervisor)

    assert_receive :inactive_received, 20_000
  end

  # ----------------------------------------
  # /data Endpoint Tests
  # ----------------------------------------

  test "testing the REST /data endpoint [JSON]" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/json"}]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /data endpoint [MSGPACK]" do
    url = @base_url <> "/data"
    {:ok, data} = Msgpax.pack(%{id: "agentID", secret: "mysecret", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/msgpack"}]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /data endpoint without content-type" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", type: "ethereum_metrics", data: %{hello: :world}})

    {415, :nobody} = post(url, data, [])
  end

  test "testing the REST /data endpoint without required fields" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /data endpoint without data field" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", type: "ethereum_metrics"})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /data endpoint with wrong data field" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", type: "ethereum_metrics", data: ""})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /data endpoint with wrong secret" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "wrong_secret", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/json"}]

    {401, :nobody} = post(url, data, headers)
  end

  # ----------------------------------------
  # /bye Endpoint Tests
  # ----------------------------------------

  test "testing the REST /bye endpoint [JSON]" do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /bye endpoint [MSGPACK]" do
    url = @base_url <> "/bye"
    {:ok, data} = Msgpax.pack(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/msgpack"}]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /bye endpoint without content-type" do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})

    {415, :nobody} = post(url, data, [])
  end

  test "testing the REST /bye endpoint without required fields" do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /bye endpoint with wrong secret" do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "wrong_secret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {401, :nobody} = post(url, data, headers)
  end

  # ----------------------------------------
  # Other Tests
  # ----------------------------------------

  test "testing an unnexisting endpoint" do
    url = @base_url <> "/thisdoesntexist"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {404, :nobody} = post(url, data, headers)
  end

  test "init calls in the plugs are not executed (possible bug in Plug)" do
    alias POABackend.CustomHandler.REST

    original_data = :original_data

    assert(original_data == REST.Plugs.Accept.init(original_data))
    assert(original_data == REST.Plugs.Authorization.init(original_data))
    assert(original_data == REST.Plugs.RequiredFields.init(original_data))
  end

  # ----------------------------------------
  # Internal functions
  # ----------------------------------------

  defp post(url, data, headers) do
    {:ok, response} = HTTPoison.post(url, data, headers)

    body = case response.status_code do
      200 ->
        {:ok, body} = Poison.decode(response.body)
        body
      _ ->
        :nobody
    end

    {response.status_code, body}
  end

  defp ping(agent_id) do
    gen_ping(agent_id, "application/json")
  end

  defp ping_msgpack(agent_id) do
    gen_ping(agent_id, "application/msgpack")
  end

  defp gen_ping(agent_id, mime_type) do
    url = @base_url <> "/ping"
    {:ok, data} = encode_ping(mime_type, agent_id)
    headers = [{"Content-Type", mime_type}]

    post(url, data, headers)
  end

  defp encode_ping("application/json", agent_id) do
    Poison.encode(%{id: agent_id, secret: "mysecret", data: %{hello: "world"}})
  end

  defp encode_ping("application/msgpack", agent_id) do
    Msgpax.pack(%{id: agent_id, secret: "mysecret", data: %{hello: "world"}})
  end

end