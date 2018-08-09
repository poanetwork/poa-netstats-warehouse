defmodule Auth.AuthTest do
  use ExUnit.Case
  alias POABackend.Auth
  alias POABackend.Ancillary.Utils

  setup do
    Utils.clear_db()

    on_exit fn ->
      Utils.clear_db()
    end

    []
  end

  # ----------------------------------------
  # User Tests
  # ----------------------------------------

  test "create a new user" do
    alias Comeonin.Bcrypt
    user_name = "ferigis"
    password = "mypassword"

    {:ok, user} = Auth.create_user(user_name, password)

    assert Bcrypt.checkpw(password, user.password_hash)
    
    {:error, :already_exists} = Auth.create_user(user_name, "mypassword")
  end

  test "get a user" do
    user_name = "ferigis"
    password = "mypassword"

    {:ok, user} = Auth.create_user(user_name, password)

    assert user == Auth.get_user(user_name)

    assert nil == Auth.get_user("otheruser")
  end

  test "remove a user" do
    user_name = "ferigis"
    password = "mypassword"

    assert nil == Auth.get_user(user_name)

    {:ok, user} = Auth.create_user(user_name, password)

    assert user == Auth.get_user(user_name)

    :ok = Auth.remove_user(user)

    assert nil == Auth.get_user(user_name)
  end

  test "activate/deactivate a user" do
    user_name = "ferigis"
    password = "mypassword"


    {:ok, user} = Auth.create_user(user_name, password)

    assert Auth.user_active?(user)
    assert {:ok, user} == Auth.authenticate_user(user_name, password)

    {:ok, _} = Auth.deactivate_user(user)
    user = Auth.get_user(user_name)

    refute Auth.user_active?(user)
    assert {:error, :notvalid} == Auth.authenticate_user(user_name, password)

    {:ok, _} = Auth.activate_user(user)
    user = Auth.get_user(user_name)

    assert Auth.user_active?(user)
    assert {:ok, user} == Auth.authenticate_user(user_name, password)
  end

  test "authenticate an admin" do
    {:ok, :valid} = Auth.authenticate_admin("admin1", "password12345678")
    {:ok, :valid} = Auth.authenticate_admin("admin2", "password87654321")
    {:error, :notvalid} = Auth.authenticate_admin("admin2", "wrong_password")
  end

  test "generate user_name [coverage]" do
    user_name = "ferigis"
    password = "mypassword"

    {:ok, _user} = Auth.create_user(user_name, password)

    user_name2 = Auth.generate_user_name(user_name)

    refute user_name == user_name2
  end

  # ----------------------------------------
  # Token Tests
  # ----------------------------------------

  test "create a banned token" do
    # first we need a user
    user_name = "ferigis"
    password = "mypassword"

    {:ok, user} = Auth.create_user(user_name, password)

    # generate a token
    {_, jwt_token, _} = Auth.Guardian.encode_and_sign(user)

    {:ok, _token} = Auth.create_banned_token(jwt_token)
    {:error, :already_exists} = Auth.create_banned_token(jwt_token)
  end

  test "create a banned token with a non JWT token" do
    {:error, %ArgumentError{}} = Auth.create_banned_token("wrongJWTToken")
  end

  test "delete expired banned tokens" do
    current_time = :os.system_time(:seconds)

    {:ok, token1} = Auth.create_banned_token("token1", current_time - 1000)
    {:ok, token2} = Auth.create_banned_token("token2", current_time + 1000)
    {:ok, token3} = Auth.create_banned_token("token3", current_time - 1000)
    {:ok, token4} = Auth.create_banned_token("token4", current_time - 1000)

    all = Auth.Repo.all(Auth.Models.Token)

    assert 4 == length(all)
    assert Enum.member?(all, token1)
    assert Enum.member?(all, token2)
    assert Enum.member?(all, token3)
    assert Enum.member?(all, token4)

    # sending a message to the process which cleans the DB
    POABackend.Auth.BanTokensServer
    |> Process.whereis()
    |> send(:purge)

    Process.sleep(1000) # wait a little until the server cleans the DB

    all = Auth.Repo.all(Auth.Models.Token)

    assert 1 == length(all)
    assert Enum.member?(all, token2)
  end

end