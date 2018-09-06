defmodule POABackend.CustomHandler.REST.Plugs.ContentType do
  @moduledoc false

  alias Plug.Conn

  @behaviour Plug

  def init(accepted_content_type) do
    accepted_content_type
  end

  def call(%Conn{method: method} = conn, accepted_content_type) when method in ["POST", "PUT"] do
    import Plug.Conn
  
    with {"content-type", content_type} <- List.keyfind(conn.req_headers, "content-type", 0),
         true <- Enum.member?(accepted_content_type, content_type)
    do
      conn
    else
      _error ->
        conn
        |> send_resp(415, "")
        |> halt
    end
  end
  def call(conn, _) do
    conn
  end

end
