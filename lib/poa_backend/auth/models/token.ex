defmodule POABackend.Auth.Models.Token do
  use Ecto.Schema

  @moduledoc """
  This module encapsulates the _Token_ model. This is used in order to store banned tokens in Database
  """

  @primary_key {:token, :string, []}

  schema "banned_tokens" do
    field :expires, :integer

    timestamps()
  end

  @type t :: %__MODULE__{token: String.t,
                         expires: Integer.t}

  def new(token, expires) do
    %__MODULE__{token: token, expires: expires}
  end
end