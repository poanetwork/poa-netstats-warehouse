defmodule POABackend.Auth do

  @moduledoc """
  This module defines the API for the Authorisation
  """

  alias POABackend.Auth.Models.User
  alias POABackend.Auth.Repo

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
  def authenticate_user(user, password) do
    alias Comeonin.Bcrypt

    with user <- get_user(user),
         true <- Bcrypt.checkpw(password, user.password_hash)
    do
      {:ok, user}
    else
      _error -> {:error, :notvalid}
    end
  end

end