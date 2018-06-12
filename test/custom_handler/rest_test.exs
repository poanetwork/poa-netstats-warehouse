defmodule CustomHandler.RESTTest do
  use ExUnit.Case

  @base_url "localhost:4002"

  # ----------------------------------------
  # /hello Endpoint Tests
  # ----------------------------------------

  test "testing the REST /hello endpoint" do
    url = @base_url <> "/hello"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /hello endpoint without content-type" do
    url = @base_url <> "/hello"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})

    {415, :nobody} = post(url, data, [])
  end

  test "testing the REST /hello endpoint without required fields" do
    url = @base_url <> "/hello"
    {:ok, data} = Poison.encode(%{id: "agentID", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /hello endpoint with wrong secret" do
    url = @base_url <> "/hello"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "wrong_secret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {401, :nobody} = post(url, data, headers)
  end

  # ----------------------------------------
  # /ping Endpoint Tests
  # ----------------------------------------

  test "testing the REST /ping endpoint" do
    url = @base_url <> "/ping"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

    {200, %{"result" => "success"}} = post(url, data, headers)
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

  # ----------------------------------------
  # /latency Endpoint Tests
  # ----------------------------------------

  test "testing the REST /latency endpoint" do
    url = @base_url <> "/latency"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", latency: 15.0})
    headers = [{"Content-Type", "application/json"}]

    {200, %{"result" => "success"}} = post(url, data, headers)
  end

  test "testing the REST /latency endpoint without content-type" do
    url = @base_url <> "/latency"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", latency: 15.0})

    {415, :nobody} = post(url, data, [])
  end

  test "testing the REST /latency endpoint without required fields" do
    url = @base_url <> "/latency"
    {:ok, data} = Poison.encode(%{id: "agentID", latency: 15.0})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /latency endpoint without latency field" do
    url = @base_url <> "/latency"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret"})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /latency endpoint with wrong latency field" do
    url = @base_url <> "/latency"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", latency: "no number"})
    headers = [{"Content-Type", "application/json"}]

    {422, :nobody} = post(url, data, headers)
  end

  test "testing the REST /latency endpoint with wrong secret" do
    url = @base_url <> "/latency"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "wrong_secret", latency: 15.0})
    headers = [{"Content-Type", "application/json"}]

    {401, :nobody} = post(url, data, headers)
  end

  # ----------------------------------------
  # /data Endpoint Tests
  # ----------------------------------------

  test "testing the REST /data endpoint" do
    url = @base_url <> "/data"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", type: "ethereum_metrics", data: %{hello: :world}})
    headers = [{"Content-Type", "application/json"}]

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

  test "testing the REST /bye endpoint" do
    url = @base_url <> "/bye"
    {:ok, data} = Poison.encode(%{id: "agentID", secret: "mysecret", data: %{hello: "world"}})
    headers = [{"Content-Type", "application/json"}]

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

    assert(original_data == REST.AcceptPlug.init(original_data))
    assert(original_data == REST.AuthorizationPlug.init(original_data))
    assert(original_data == REST.RequiredFieldsPlug.init(original_data))
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

end