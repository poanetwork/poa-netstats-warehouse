defmodule Auth.UserAPITest do
  use POABackend.Ancillary.CommonAPITest

  @url @base_url <> "/user"
  
  test "trying to create a user with wrong Admin Credentials [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "trying to create a user with wrong Admin Credentials [MSGPACK]" do 
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert {401, :nobody} == result
  end

  test "create a user without credentials [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, %{"user-name" => user_name, "password" => password}} =
      %{:'agent-id' => "agentID"}
      |> Poison.encode!()
      |> post(@url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user without credentials [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, %{"user-name" => user_name, "password" => password}} =
      %{:'agent-id' => "agentID"}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]
    user_name = "newUserName"

    {200, %{"user-name" => ^user_name, "password" => password}} =
      %{:'agent-id' => "agentID", :'user-name' => user_name}
      |> Poison.encode!()
      |> post(@url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]
    user_name = "newUserName"

    {200, %{"user-name" => ^user_name, "password" => password}} =
      %{:'agent-id' => "agentID", :'user-name' => user_name}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name and password [JSON]" do
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
      |> post(@url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create a user with user_name and password [MSGPACK]" do
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
      |> post(@url, headers)

    assert Auth.authenticate_user(user_name, password)
  end

  test "create user which already exists [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:'agent-id' => "agentID",
        :'user-name' => @user}
      |> Poison.encode!()
      |> post(@url, headers)

    assert {409, :nobody} == result
  end

  test "create user which already exists [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{:'agent-id' => "agentID",
        :'user-name' => @user}
      |> Msgpax.pack!()
      |> post(@url, headers)

    assert {409, :nobody} == result
  end

  test "listing all the users stored" do
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user] = users} = get(@url, headers)

    assert length(users) == 1 # ferigis user is created at the begining of each test
    assert initial_user["user"] == "ferigis"

    :ok = create_user("user2", "password2")

    {200, users} = get(@url, headers)

    assert length(users) == 2
  end

  test "listing all the users stored with wrong Admin Credentials" do
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result = get(@url, headers)

    assert {401, :nobody} == result
  end

  test "deleting a user which exists in the system" do
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user] = users} = get(@url, headers)

    assert length(users) == 1 # ferigis user is created at the begining of each test
    assert initial_user["user"] == "ferigis"

    assert {204, :nobody} == delete(@url <> "/ferigis", headers)

    assert {200, []} == get(@url, headers)
  end

  test "deleting a user which doern't exist in the system" do
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user] = users} = get(@url, headers)

    assert length(users) == 1 # ferigis user is created at the begining of each test
    assert initial_user["user"] == "ferigis"

    assert {404, :nobody} == delete(@url <> "/noexist", headers)

    {200, ^users} = get(@url, headers)
  end

  test "deleting a user with wrong admin credentials" do
    headers = [
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    assert {401, :nobody} == delete(@url <> "/ferigis", headers)
  end

  test "updating user [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]

    result =
      %{}
      |> Map.put(:active, false)
      |> Poison.encode!
      |> patch(@url <> "/ferigis", headers)
    
    assert {204, :nobody} == result

    {200, [initial_user]} = get(@url, headers)

    refute initial_user["active"]

    result =
      %{}
      |> Map.put(:active, true)
      |> Poison.encode!
      |> patch(@url <> "/ferigis", headers)
    
    assert {204, :nobody} == result

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]
  end

  test "updating user [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]

    result =
      %{}
      |> Map.put(:active, false)
      |> Msgpax.pack!
      |> patch(@url <> "/ferigis", headers)
    
    assert {204, :nobody} == result

    {200, [initial_user]} = get(@url, headers)

    refute initial_user["active"]

    result =
      %{}
      |> Map.put(:active, true)
      |> Msgpax.pack!
      |> patch(@url <> "/ferigis", headers)
    
    assert {204, :nobody} == result

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]
  end

  test "updating user with wrong active value (not boolean) [JSON]" do    
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]

    result =
      %{}
      |> Map.put(:active, "wrong value")
      |> Poison.encode!
      |> patch(@url <> "/ferigis", headers)
    
    assert {422, :nobody} == result

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]
  end

  test "updating user with wrong active value (not boolean) [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]

    result =
      %{}
      |> Map.put(:active, "wrong value")
      |> Msgpax.pack!
      |> patch(@url <> "/ferigis", headers)
    
    assert {422, :nobody} == result

    {200, [initial_user]} = get(@url, headers)

    assert initial_user["active"]
  end

  test "updating user with wrong admin credentials [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{}
      |> Map.put(:active, false)
      |> Poison.encode!
      |> patch(@url <> "/ferigis", headers)
    
    assert {401, :nobody} == result
  end

  test "updating user with wrong admin credentials [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> "wrongpassword")}
    ]

    result =
      %{}
      |> Map.put(:active, false)
      |> Msgpax.pack!
      |> patch(@url <> "/ferigis", headers)
    
    assert {401, :nobody} == result
  end

  test "updating user who doesn't exist [JSON]" do
    mime_type = "application/json"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{}
      |> Map.put(:active, true)
      |> Poison.encode!
      |> patch(@url <> "/unnexistinguser", headers)
    
    assert {404, :nobody} == result
  end

  test "updating user who doesn't exist [MSGPACK]" do
    mime_type = "application/msgpack"
    headers = [
      {"Content-Type", mime_type},
      {"authorization", "Basic " <> Base.encode64(@admin <> ":" <> @admin_pwd)}
    ]

    result =
      %{}
      |> Map.put(:active, true)
      |> Msgpax.pack!
      |> patch(@url <> "/unnexistinguser", headers)
    
    assert {404, :nobody} == result
  end
end