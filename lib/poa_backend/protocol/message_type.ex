defmodule POABackend.Protocol.MessageType do

  @moduledoc """
  Regarding the POA Protocol only 3 types of message can be processed in the backend.

  Those message types are

  * `hello` - When the communication starts
  * `data` - When data is sent to the backend. Data is also called "metric data"
  * `latency` - When the agent sent the latency value

  """
  
  @typedoc """
  The message type. Only `hello`, `data` and `latency` are allowed
  """
  @type t :: :hello | :data | :latency

end