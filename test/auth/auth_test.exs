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
end