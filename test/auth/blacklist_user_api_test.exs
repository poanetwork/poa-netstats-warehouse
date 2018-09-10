defmodule Auth.BlacklistUserAPITest do
  use POABackend.Ancillary.CommonAPITest

  @url @base_url <> "/blacklist/user"
  @session_url @base_url <> "/session"

  test "Ban a user correctly [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@session_url, headers)

    user = Auth.get_user(@user)

    assert Auth.valid_token?(jwt_token)
    assert Auth.user_active?(user)

    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:user => @user}
      |> Poison.encode!()
      |> post(@url, headers)

    user = Auth.get_user(@user)

    refute Auth.valid_token?(jwt_token)
    refute Auth.user_active?(user)
  end

  test "Ban a user correctly [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@session_url, headers)

    user = Auth.get_user(@user)

    assert Auth.valid_token?(jwt_token)
    assert Auth.user_active?(user)

    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:user => @user}
      |> Msgpax.pack!()
      |> post(@url, headers)

    user = Auth.get_user(@user)

    refute Auth.valid_token?(jwt_token)
    refute Auth.user_active?(user)
  end

  test "Ban a user who doesn't exist [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:user => "thiUserDoesntexist"}
      |> Poison.encode!()
      |> post(@url, headers)

    assert result == {404, :nobody}
  end

  test "Ban a user who doesn't exist [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:user => "thiUserDoesntexist"}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert result == {404, :nobody}
  end

  test "Ban user with wrong Admin credentials [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:user => @user}
      |> Poison.encode!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "Ban user with wrong Admin credentials [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:user => @user}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "Ban user without user field [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result = post("", @url, headers)

    assert {404, :nobody} == result
  end
end