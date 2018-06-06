defmodule POABackend.Protocol.DataType do
  
  @moduledoc """
  The protocol messages Data type.

  Only one Data type is supported now in the backend and it is the ethereum metric
  """

  @typedoc """
  The Message Data Type. For now only ethereum metrics allowed
  """
  @type t :: :ethereum_metric

end