defmodule CustomHandler.RESTTest do
  use ExUnit.Case

  alias POABackend.CustomHandler.REST.Monitor
  alias POABackend.Ancillary.Utils
  alias POABackend.Auth

  @base_url "localhost:4002"
  @user "myuser1"
  @password "1234567890"

  setup_all do
    Utils.clear_db()
    user = create_user()
    {:ok, token, _} = POABackend.Auth.Guardian.encode_and_sign(user)

    on_exit fn ->
      Utils.clear_db()
    end

    [token: token,
     auth_header: {"Authorization", "Bearer " <> token}]
  end

  # ----------------------------------------
  # /ping Endpoint Tests
  # ----------------------------------------

  test "testing the REST /ping endpoint [JSON]", context do
    {200, %{"result" => "success"}} = ping("agentID", context.token)
  end

  test "testing the REST /ping endpoint [MSGPACK]", context do
    {200, %{"result" => "success"}} = ping("agentID", context.token)
  end

  test "testing the REST /ping endpoint without content-type", context do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})

    {415, :nobody} = post(url, data, [context.auth_header])
  end

  test "testing the REST /ping endpoint without required fields", context do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /ping endpoint with wrong auth" do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"},
               {"Authorization", "Bearer mytoken"}]

    {401, :nobody} = post(url, data, headers)
  end

  test "testing the REST /ping endpoint without auth" do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {401, :nobody} = post(url, data, headers)
  end

  test "POST /ping send inactive after stopping sending pings", context do
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

    {200, %{"result" => "success"}} = ping(agent_id, context.token)

    active_monitors = active_monitors + 1

    %{active: ^active_monitors} = Supervisor.count_children(Monitor.Supervisor)

    {200, %{"result" => "success"}} = ping_msgpack(agent_id, context.token)

    %{active: ^active_monitors} = Supervisor.count_children(Monitor.Supervisor)

    assert_receive :inactive_received, 20_000
  end

  # ----------------------------------------
  # /data Endpoint Tests
  # ----------------------------------------

  test "testing the REST /data endpoint [JSON]", context do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /data endpoint [MSGPACK]", context do
    url = @base_url <> "/data"
    {:ok, data} = Msgpax.pack(%{id: "agentID", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/msgpack"}, context.auth_header]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /data endpoint without content-type", context do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", type: "ethereum_metrics", data: %{hello: :world}})

    {415, :nobody} = post(url, data, [context.auth_header])
  end

  test "testing the REST /data endpoint without required fields", context do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /data endpoint without data field", context do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", type: "ethereum_metrics"})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /data endpoint with wrong data field", context do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", type: "ethereum_metrics", data: ""})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /data endpoint with wrong auth" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/json"},
               {"Authorization", "Bearer mytoken"}]

    {401, :nobody} = post(url, data, headers)
  end

  # ----------------------------------------
  # /bye Endpoint Tests
  # ----------------------------------------

  test "testing the REST /bye endpoint [JSON]", context do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /bye endpoint [MSGPACK]", context do
    url = @base_url <> "/bye"
    {:ok, data} = Msgpax.pack(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/msgpack"}, context.auth_header]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /bye endpoint without content-type", context do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})

    {415, :nobody} = post(url, data, [context.auth_header])
  end

  test "testing the REST /bye endpoint without required fields", context do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /bye endpoint with wrong auth" do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"},
               {"Authorization", "Bearer mytoken"}]

    {401, :nobody} = post(url, data, headers)
  end

  # ----------------------------------------
  # Other Tests
  # ----------------------------------------

  test "testing an unnexisting endpoint", context do
    url = @base_url <> "/thisdoesntexist"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}, context.auth_header]

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

  defp create_user do
    {:ok, user} = Auth.create_user(@user, @password)
    user
  end

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

  defp ping(agent_id, auth_token) do
    gen_ping(agent_id, "application/json", auth_token)
  end

  defp ping_msgpack(agent_id, auth_token) do
    gen_ping(agent_id, "application/msgpack", auth_token)
  end

  defp gen_ping(agent_id, mime_type, auth_token) do
    url = @base_url <> "/ping"
    {:ok, data} = encode_ping(mime_type, agent_id)
    headers = [{"Content-Type", mime_type},
               {"Authorization", "Bearer " <> auth_token}]

    post(url, data, headers)
  end

  defp encode_ping("application/json", agent_id) do
    Poison.encode(%{id: agent_id, data: %{hello: "world"}})
  end

  defp encode_ping("application/msgpack", agent_id) do
    Msgpax.pack(%{id: agent_id, data: %{hello: "world"}})
  end

end