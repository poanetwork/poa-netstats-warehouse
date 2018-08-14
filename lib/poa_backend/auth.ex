defmodule POABackend.Auth do

  @moduledoc """
  This module defines the API for the Authorisation
  """

  alias POABackend.Auth.Models.User
  alias POABackend.Auth.Repo
  alias POABackend.Auth

  @doc """
  Registers a user in the system.
  """
  @spec create_user(String.t, String.t, Boolean.t) :: {:ok, User.t} | {:error, :already_exists} | {:error, Ecto.Changeset.t}
  def create_user(user_name, password, active \\ true) do
    try do
      %User{}
      |> User.changeset(%{user: user_name,
                          password: password,
                          active: active})
      |> Repo.insert
    rescue
      x in CaseClauseError -> x.term
    end
  end

  @doc """
  Get a user from the database based in the user name
  """
  @spec get_user(String.t) :: User.t | nil
  def get_user(user) do
    Repo.get(User, user)
  end

  @doc """
  Deletes a user from the database based in the given user
  """
  @spec remove_user(User.t) :: :ok
  def remove_user(user) do
    _ = Repo.delete(user)
    :ok
  end

  @doc """
  This function Activates a user, storing `active: true` in the database for the given user
  """
  @spec activate_user(User.t) :: {:ok, User.t} | {:error, Ecto.Changeset.t}
  def activate_user(user) do
    user
    |> User.changeset(%{active: true})
    |> Repo.update
  end

  @doc """
  This function Deactivates a user, storing `active: false` in the database for the given user
  """
  @spec deactivate_user(User.t) :: {:ok, User.t} | {:error, Ecto.Changeset.t}
  def deactivate_user(user) do
    user
    |> User.changeset(%{active: false})
    |> Repo.update
  end

  @doc """
  Checks if a user is active
  """
  @spec user_active?(User.t) :: Boolean.t
  def user_active?(%User{active: true}), do: true
  def user_active?(%User{active: _}), do: false

  @doc """
  This function authenticates a user/password pair
  """
  @spec authenticate_user(String.t, String.t) :: {:ok, User.t} | {:error, :notvalid}
  def authenticate_user(user_name, password) do
    alias Comeonin.Bcrypt

    with user <- get_user(user_name),
         true <- Bcrypt.checkpw(password, user.password_hash),
         true <- user_active?(user)
    do
      {:ok, user}
    else
      _error -> {:error, :notvalid}
    end
  end

  @doc """
  Authenticates an Admin
  """
  @spec authenticate_admin(String.t, String.t) :: {:ok, :valid} | {:error, :notvalid}
  def authenticate_admin(admin_name, password) do
    with admins <- Application.get_env(:poa_backend, :admins),
         true <- Enum.member?(admins, {admin_name, password})
    do
      {:ok, :valid}
    else
      _error -> {:error, :notvalid}
    end
  end

  @doc """
  Generates a valid user name randomply
  """
  @spec generate_user_name() :: String.t
  def generate_user_name do
    8
    |> random_string()
    |> generate_user_name()
  end

  @doc """
  This function is exported for testing purposes
  """
  @spec generate_user_name(String.t) :: String.t
  def generate_user_name(user_name) do
    case valid_user_name?(user_name) do
      true -> user_name
      false -> generate_user_name()
    end
  end

  @doc """
  Generates a password randomply
  """
  @spec generate_password() :: String.t
  def generate_password do
    random_string(15)
  end

  @doc """
  Validates if a given user name is valid or not. It is valid if doesn't exist a user
  with that name in the database already
  """
  @spec valid_user_name?(String.t) :: Boolean.t
  def valid_user_name?(user_name) do
    case get_user(user_name) do
      nil -> true
      _ -> false
    end
  end

  @doc """
  Validates if a JWT token is valid.
  """
  @spec valid_token?(String.t) :: Boolean.t | {:error, :token_expired}
  def valid_token?(jwt_token) do
    with {:ok, claims} <- Auth.Guardian.decode_and_verify(jwt_token),
         {:ok, user, ^claims} <- Auth.Guardian.resource_from_token(jwt_token),
         true <- user_active?(user)
    do
      true
    else
      {:error, :token_expired} = result ->
        result
      _error -> false
    end
  end

  # ---------------------------------------
  # Private Functions
  # ---------------------------------------

  defp random_string(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end