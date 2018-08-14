defmodule POABackend.Auth.Models.User do
  use Ecto.Schema
  alias __MODULE__
  import Ecto.Changeset

  @moduledoc """
  This module encapsulates the _User_ model
  """

  @primary_key {:user, :string, []}

  schema "users" do
    field :password_hash, :string
    field :password, :string, virtual: true
    field :active, :boolean, default: true

    timestamps()
  end

  @type t :: %__MODULE__{user: String.t,
                         password_hash: String.t,
                         password: String.t,
                         active: :boolean}

  def changeset(%User{} = user, params \\ %{}) do
    user
    |> cast(params, ~w(user password active))
    |> validate_required([:user])
    |> validate_length(:password, min: 8)
    |> unique_constraint(:user)
    |> put_password_hash()
  end

  defp put_password_hash(%{changes: %{password: password}} = changeset) do
    alias Comeonin.Bcrypt

    changeset
    |> put_change(:password_hash, Bcrypt.hashpwsalt(password))
    |> put_change(:password, nil)
  end
  defp put_password_hash(%{changes: %{}} = changeset), do: changeset
end