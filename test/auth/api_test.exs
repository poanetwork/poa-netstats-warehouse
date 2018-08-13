defmodule Auth.APITest do
  use ExUnit.Case
  alias POABackend.Auth
  alias POABackend.Ancillary.Utils

  @base_url "https://localhost:4003"
  @user "ferigis"
  @password "1234567890"

  setup do
    Utils.clear_db()
    :ok = create_user()

    on_exit fn ->
      Utils.clear_db()
    end

    []
  end

  # ----------------------------------------
  # /session Endpoint Tests
  # ----------------------------------------

  test "get a valid JWT Token with [JSON]" do
    url = @base_url <> "/session"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(url, headers)

    user = Auth.get_user(@user)
    {:ok, claims} = Auth.Guardian.decode_and_verify(jwt_token)

    assert {:ok, user, claims} == Auth.Guardian.resource_from_token(jwt_token)
  end

  test "get a valid JWT Token with [MSGPACK]" do
    url = @base_url <> "/session"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]
    
    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(url, headers)

    user = Auth.get_user(@user)
    {:ok, claims} = Auth.Guardian.decode_and_verify(jwt_token)

    assert {:ok, user, claims} == Auth.Guardian.resource_from_token(jwt_token)
  end

  test "try with wrong user/password [JSON]" do
    url = @base_url <> "/session"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "try with wrong user/password [MSGPACK]" do
    url = @base_url <> "/session"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "testing an unnexisting endpoint" do
    url = @base_url <> "/thisdoesntexist"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(url, headers)

    assert {404, :nobody} == result
  end

  # ----------------------------------------
  # Internal functions
  # ----------------------------------------

  defp create_user do
    {:ok, _user} = Auth.create_user(@user, @password)
    :ok
  end

  defp post(data, url, headers) do
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
    {:ok, response} = HTTPoison.post(url, data, headers, options)

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
