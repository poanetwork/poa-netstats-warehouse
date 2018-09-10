defmodule Auth.SessionAPITest do
  use POABackend.Ancillary.CommonAPITest

  @url @base_url <> "/session"

  test "get a valid JWT Token with [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@url, headers)

    user = Auth.get_user(@user)
    {:ok, claims} = Auth.Guardian.decode_and_verify(jwt_token)

    assert {:ok, user, claims} == Auth.Guardian.resource_from_token(jwt_token)
  end

  test "get a valid JWT Token with [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]
    
    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@url, headers)

    user = Auth.get_user(@user)
    {:ok, claims} = Auth.Guardian.decode_and_verify(jwt_token)

    assert {:ok, user, claims} == Auth.Guardian.resource_from_token(jwt_token)
  end

  test "try with wrong user/password [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "try with wrong user/password [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "try with a user who doesn't exist [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64("nonexistinguser" <> ":" <> "password")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "try with a user who doesn't exist [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64("nonexistinguser" <> ":" <> "password")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "testing an unnexisting endpoint" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@base_url <> "/thisdoesntexist", headers)

    assert {404, :nobody} == result
  end

end