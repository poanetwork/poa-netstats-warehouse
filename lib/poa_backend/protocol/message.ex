defmodule POABackend.Protocol.Message do
  alias __MODULE__
  alias POABackend.CustomProtocol.DataType
  alias POABackend.CustomProtocol.MessageType
  
  @moduledoc """
  The message received from the Agent (inspired in [`Plug.Conn`](https://hexdocs.pm/plug/Plug.Conn.html)).

  This module defines the Message received from the Agent and the main functions in order
  to work with it.

  ## Message Fields

    * `agent_id` - The Agent Id which sent the message to the backend.
    * `data_type` - The kind of data the message is carring. For now only `ethereum_metric` type is defined.
    * `message_type` - This is the message type according to the custom protocol. Only `data` and `bye` are defined for now
    * `assigns` - Shared user data as a map
    * `data` - The message payloda. It is a map

  """

  defstruct [
    agent_id: nil,
    data_type: nil,
    message_type: nil,
    assigns: %{},
    data: nil
  ]

  @typedoc """
  The Message struct.

  That keeps all the message data and metadata
  """
  @type t :: %__MODULE__{
    agent_id: String.t() | nil,
    data_type: DataType.t() | nil,
    message_type: MessageType.t() | nil,
    assigns: %{atom() => any()},
    data: Map.t() | nil
  }

  @doc """
  Returns a new Message Struct
  """
  @spec new() :: t
  def new() do
    %Message{}
  end

  @doc """
  Returns a new Message Struct initialized.
  The params in order are: agent_id, data_type, message_type and data
  """
  @spec new(String.t, DataType.t, MessageType.t, Map.t) :: t
  def new(agent_id, data_type, message_type, data) do
    %Message{
      agent_id: agent_id,
      data_type: data_type,
      message_type: message_type,
      data: data
    }
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