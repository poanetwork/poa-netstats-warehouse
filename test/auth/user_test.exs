defmodule Auth.UserTest do
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

    password = "mypassword"

    {:ok, user} = Auth.create_user("ferigis", password)

    assert Bcrypt.checkpw(password, user.password_hash)
    
    {:error, :already_exists} = Auth.create_user("ferigis", "mypassword")
  end

  test "get a user" do
    {:ok, user} = Auth.create_user("ferigis", "mypassword")

    assert user == Auth.get_user("ferigis")

    assert nil == Auth.get_user("otheruser")
  end

  test "remove a user" do
    assert nil == Auth.get_user("ferigis")

    {:ok, user} = Auth.create_user("ferigis", "mypassword")

    assert user == Auth.get_user("ferigis")

    :ok = Auth.remove_user(user)

    assert nil == Auth.get_user("ferigis")
  end

  test "activate/deactivate a user" do
    {:ok, user} = Auth.create_user("ferigis", "mypassword")

    assert Auth.user_active?(user)

    {:ok, _} = Auth.deactivate_user(user)
    user = Auth.get_user("ferigis")

    refute Auth.user_active?(user)

    {:ok, _} = Auth.activate_user(user)
    user = Auth.get_user("ferigis")

    assert Auth.user_active?(user)
  end
end