defmodule POABackend.Protocol.Message do
  alias __MODULE__
  
  @moduledoc """
  The message received from the Agent (inspired in [`Plug.Conn`](https://hexdocs.pm/plug/Plug.Conn.html)).

  This module defines the Message received from the Agent and the main functions in order
  to work with it.

  ## Message Fields

    * `agent_id` - The Agent Id which sent the message to the backend.
    * `receivers` - The list of the receivers which are going to receive this message. This list is retrieved from the config file and is mapped to the `data_type`
    * `data_type` - The kind of data the message is carring. For now only `ethereum_metric` type is defined.
    * `message_type` - This is the message type according to the custom protocol. Only `hello`, `data` and `latency` are defined
    * `assigns` - Shared user data as a map
    * `peer` - The actual TCP peer that connected, example: `{{127, 0, 0, 1}, 12345}`.
    * `data` - The message payloda. It is a map

  """

  defstruct [
    agent_id: nil,
    receivers: [],
    data_type: nil,
    message_type: nil,
    assigns: %{},
    peer: nil,
    data: nil
  ]

  @typedoc """
  The Message struct.

  That keeps all the message data and metadata
  """
  @type t :: %__MODULE__{
    agent_id: String.t(),
    receivers: [atom()],
    data_type: POABackend.CustomProtocol.DataType.t(),
    message_type: POABackend.CustomProtocol.MessageType.t(),
    assigns: %{atom() => any()},
    peer: {:inet.ip_address(), :inet.port_number()},
    data: Map.t()
  }

  @doc """
  Returns a new Message Struct
  """
  @spec new() :: t
  def new() do
    %Message{}
  end

  @doc """
  Assigns a value to a key in the connection.

  ## Examples
      iex> alias POABackend.Protocol.Message
      iex> message = Message.new()
      iex> message.assigns[:hello]
      nil
      iex> message = Message.assign(message, :hello, :world)
      iex> message.assigns[:hello]
      :world
  """
  @spec assign(t, atom, term) :: t
  def assign(%Message{assigns: assigns} = message, key, value) when is_atom(key) do
    %{message | assigns: Map.put(assigns, key, value)}
  end

end