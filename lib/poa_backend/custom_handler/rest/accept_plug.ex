defmodule POABackend.CustomHandler.REST.AcceptPlug do
  @moduledoc false

  @behaviour Plug

  def init(accept) do
    accept
  end

  def call(conn, accept) do
    import Plug.Conn
    
    case List.keyfind(conn.req_headers, "content-type", 0) do
      {"content-type", ^accept} ->
        conn
      _ -> 
        conn
        |> send_resp(415, "")
        |> halt
    end
  end

end
