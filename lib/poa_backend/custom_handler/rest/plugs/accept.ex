defmodule POABackend.CustomHandler.REST.Plugs.Accept do
  @moduledoc false

  @behaviour Plug

  def init(accept) do
    accept
  end

  def call(conn, accept) do
    import Plug.Conn
    
    with {"content-type", content_type} <- List.keyfind(conn.req_headers, "content-type", 0),
         true <- Enum.member?(accept, content_type)
    do
      conn
    else
      _error ->
        conn
        |> send_resp(415, "")
        |> halt
    end
  end

end
