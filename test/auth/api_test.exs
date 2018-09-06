defmodule Auth.APITest do
  use ExUnit.Case
  alias POABackend.Auth
  alias POABackend.Ancillary.Utils

  @base_url "https://localhost:4003"
  @user "ferigis"
  @password "1234567890"
  @admin "admin1"
  @admin_pwd "password12345678"

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

  test "try with a user who doesn't exist [JSON]" do
    url = @base_url <> "/session"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64("nonexistinguser" <> ":" <> "password")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "try with a user who doesn't exist [MSGPACK]" do
    url = @base_url <> "/session"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64("nonexistinguser" <> ":" <> "password")}
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
  # /user Endpoint Tests
  # ----------------------------------------

  test "trying to create a user with wrong Admin Credentials [JSON]" do
    url = @base_url <> "/user"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "trying to create a user with wrong Admin Credentials [MSGPACK]" do
    url = @base_url <> "/user"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "create a user without credentials [JSON]" do
    url = @base_url <> "/user"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, %{"user-name" => user_name, "password" => password}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user without credentials [MSGPACK]" do
    url = @base_url <> "/user"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, %{"user-name" => user_name, "password" => password}} =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name [JSON]" do
    url = @base_url <> "/user"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]
    user_name = "newUserName"

    {200, %{"user-name" => ^user_name, "password" => password}} =
      %{:'agent-id' => "agentID", :'user-name' => user_name}
      |> Poison.encode!()
      |> post(url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name [MSGPACK]" do
    url = @base_url <> "/user"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]
    user_name = "newUserName"

    {200, %{"user-name" => ^user_name, "password" => password}} =
      %{:'agent-id' => "agentID", :'user-name' => user_name}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name and password [JSON]" do
    url = @base_url <> "/user"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]
    user_name = "newUserName2"
    password = "mypasswordfornewuser"

    {200, %{"user-name" => ^user_name, "password" => ^password}} =
      %{:'agent-id' => "agentID",
        :'user-name' => user_name,
        :password => password}
      |> Poison.encode!()
      |> post(url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name and password [MSGPACK]" do
    url = @base_url <> "/user"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]
    user_name = "newUserName2"
    password = "mypasswordfornewuser"

    {200, %{"user-name" => ^user_name, "password" => ^password}} =
      %{:'agent-id' => "agentID",
        :'user-name' => user_name,
        :password => password}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create user which already exists [JSON]" do
    url = @base_url <> "/user"
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:'agent-id' => "agentID",
        :'user-name' => @user}
      |> Poison.encode!()
      |> post(url, headers)

    assert {409, :nobody} == result
  end

  test "create user which already exists [MSGPACK]" do
    url = @base_url <> "/user"
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:'agent-id' => "agentID",
        :'user-name' => @user}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert {409, :nobody} == result
  end

  test "listing all the users stored" do
    url = @base_url <> "/user"
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user] = users} = get(url, headers)

    assert length(users) == 1 # ferigis user is created at the begining of each test
    assert initial_user["user"] == "ferigis"

    :ok = create_user("user2", "password2")

    {200, users} = get(url, headers)

    assert length(users) == 2
  end

  test "listing all the users stored with wrong Admin Credentials" do
    url = @base_url <> "/user"
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result = get(url, headers)

    assert {401, :nobody} == result
  end

  test "deleting a user which exists in the system" do
    url = @base_url <> "/user"
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user] = users} = get(url, headers)

    assert length(users) == 1 # ferigis user is created at the begining of each test
    assert initial_user["user"] == "ferigis"

    assert {204, :nobody} == delete(url <> "/ferigis", headers)

    assert {200, []} == get(url, headers)
  end

  test "deleting a user which doern't exist in the system" do
    url = @base_url <> "/user"
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user] = users} = get(url, headers)

    assert length(users) == 1 # ferigis user is created at the begining of each test
    assert initial_user["user"] == "ferigis"

    assert {404, :nobody} == delete(url <> "/noexist", headers)

    {200, ^users} = get(url, headers)
  end

  test "deleting a user with wrong admin credentials" do
    url = @base_url <> "/user"
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    assert {401, :nobody} == delete(url <> "/ferigis", headers)
  end

  # ----------------------------------------
  # /blacklist/user Endpoint Tests
  # ----------------------------------------

  test "Ban a user correctly [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@base_url <> "/session", headers)

    user = Auth.get_user(@user)

    assert Auth.valid_token?(jwt_token)
    assert Auth.user_active?(user)

    blacklist_url = @base_url <> "/blacklist/user"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:user => @user}
      |> Poison.encode!()
      |> post(blacklist_url, headers)

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
      |> post(@base_url <> "/session", headers)

    user = Auth.get_user(@user)

    assert Auth.valid_token?(jwt_token)
    assert Auth.user_active?(user)

    blacklist_url = @base_url <> "/blacklist/user"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:user => @user}
      |> Msgpax.pack!()
      |> post(blacklist_url, headers)

    user = Auth.get_user(@user)

    refute Auth.valid_token?(jwt_token)
    refute Auth.user_active?(user)
  end

  test "Ban a user who doesn't exist [JSON]" do
    mime_type = "application/json"
    url = @base_url <> "/blacklist/user"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:user => "thiUserDoesntexist"}
      |> Poison.encode!()
      |> post(url, headers)

    assert result == {404, :nobody}
  end

  test "Ban a user who doesn't exist [MSGPACK]" do
    mime_type = "application/msgpack"
    url = @base_url <> "/blacklist/user"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:user => "thiUserDoesntexist"}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert result == {404, :nobody}
  end

  test "Ban user with wrong Admin credentials [JSON]" do
    mime_type = "application/json"
    url = @base_url <> "/blacklist/user"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:user => @user}
      |> Poison.encode!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "Ban user with wrong Admin credentials [MSGPACK]" do
    mime_type = "application/msgpack"
    url = @base_url <> "/blacklist/user"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:user => @user}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "Ban user without user field [JSON]" do
    mime_type = "application/json"
    url = @base_url <> "/blacklist/user"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result = post("", url, headers)

    assert {404, :nobody} == result
  end

  # ----------------------------------------
  # /blacklist/token Endpoint Tests
  # ----------------------------------------

  test "Ban a token correctly [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@user <> ":" <> @password)}
    ]

    {200, %{"token" => jwt_token}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@base_url <> "/session", headers)

    assert Auth.valid_token?(jwt_token)

    blacklist_url = @base_url <> "/blacklist/token"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:token => jwt_token}
      |> Poison.encode!()
      |> post(blacklist_url, headers)

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
      |> post(@base_url <> "/session", headers)

    assert Auth.valid_token?(jwt_token)

    blacklist_url = @base_url <> "/blacklist/token"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, :nobody} =
      %{:token => jwt_token}
      |> Msgpax.pack!()
      |> post(blacklist_url, headers)

    refute Auth.valid_token?(jwt_token)
  end

  test "Ban an invalid token [JSON]" do
    mime_type = "application/json"
    url = @base_url <> "/blacklist/token"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:token => "badtoken"}
      |> Poison.encode!()
      |> post(url, headers)

    assert result == {404, :nobody}
  end

  test "Ban an invalid token [MSGPACK]" do
    mime_type = "application/msgpack"
    url = @base_url <> "/blacklist/token"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:token => "badtoken"}
      |> Msgpax.pack!()
      |> post(url, headers)

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
      |> post(@base_url <> "/session", headers)
    url = @base_url <> "/blacklist/token"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:token => jwt_token}
      |> Poison.encode!()
      |> post(url, headers)

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
      |> post(@base_url <> "/session", headers)
    url = @base_url <> "/blacklist/token"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:token => jwt_token}
      |> Msgpax.pack!()
      |> post(url, headers)

    assert {401, :nobody} == result
  end

  test "Ban token without token field [JSON]" do
    mime_type = "application/json"
    url = @base_url <> "/blacklist/token"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result = post("", url, headers)

    assert {404, :nobody} == result
  end

  # ----------------------------------------
  # Internal functions
  # ----------------------------------------

  defp create_user(user \\ @user, password \\ @password) do
    {:ok, _user} = Auth.create_user(user, password)
    :ok
  end

  defp post(data, url, headers) do
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
    {:ok, response} = HTTPoison.post(url, data, headers, options)

    body = case response.body do
      "" ->
        :nobody
      _ ->
        {:ok, body} = Poison.decode(response.body)
        body
    end

    {response.status_code, body}
  end

  defp get(url, headers) do
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
    {:ok, response} = HTTPoison.get(url, headers, options)

    body = case response.body do
      "" ->
        :nobody
      _ ->
        {:ok, body} = Poison.decode(response.body)
        body
    end

    {response.status_code, body}
  end

  defp delete(url, headers) do
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
    {:ok, response} = HTTPoison.delete(url, headers, options)

    body = case response.body do
      "" ->
        :nobody
      _ ->
        {:ok, body} = Poison.decode(response.body)
        body
    end

    {response.status_code, body}
  end

end
