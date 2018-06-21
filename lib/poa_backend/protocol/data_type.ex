defmodule POABackend.Protocol.DataType do
  
  @moduledoc """
  The protocol messages Data type.

  Only one Data type is supported now in the backend and it is the ethereum metric
  """

  @typedoc """
  The Message Data Type. For now only ethereum metrics allowed
  """
  @type t :: :ethereum_metric

  @doc false
  def valid?(type) when is_binary(type) do
    type
    |> String.to_existing_atom()
    |> valid?()
  end

  def valid?(type) when is_atom(type) do
    valid_types = Application.get_env(:poa_backend, :metrics)

    Enum.member?(valid_types, type)
  end

end