defmodule POABackend.Protocol.MessageType do

  @moduledoc """
  Regarding the POA Protocol only 2 types of message can be processed in the backend.

  Those message types are

  * `data` - When data is sent to the backend. Data is also called "metric data"
  * `bye` - When the client wants to stop the communication

  __NOTE__ New message types can be added in future while the protocol is extended

  """
  
  @typedoc """
  The message type. Only `data` and `bye` are allowed
  """
  @type t :: :data | :bye

end