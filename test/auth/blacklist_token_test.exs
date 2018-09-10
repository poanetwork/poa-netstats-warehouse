defmodule Auth.BlacklistTokenAPITest do
  use POABackend.Ancillary.CommonAPITest

  @url @base_url <> "/blacklist/token"
  @session_url @base_url <> "/session"

  test "Ban a token correctly [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@session_url, headers)

    assert Auth.valid_token?(jwt_token)

    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:token => jwt_token}
      |> Poison.encode!()
      |> post(@url, headers)

    refute Auth.valid_token?(jwt_token)
  end

  test "Ban a token correctly [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@session_url, headers)

    assert Auth.valid_token?(jwt_token)

    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:token => jwt_token}
      |> Msgpax.pack!()
      |> post(@url, headers)

    refute Auth.valid_token?(jwt_token)
  end

  test "Ban an invalid token [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:token => "badtoken"}
      |> Poison.encode!()
      |> post(@url, headers)

    assert result == {404, :nobody}
  end

  test "Ban an invalid token [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:token => "badtoken"}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert result == {404, :nobody}
  end

  test "Ban token with wrong Admin credentials [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@session_url, headers)

    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:token => jwt_token}
      |> Poison.encode!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "Ban token with wrong Admin credentials [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@session_url, headers)
    
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:token => jwt_token}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "Ban token without token field [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result = post("", @url, headers)

    assert {404, :nobody} == result
  end
end