defmodule POABackend.CustomHandler.REST.Plugs.Authorization do
  @moduledoc false

  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    import Plug.Conn

    secret = conn.params["secret"]

    case Application.get_env(:poa_backend, :secret) do
      ^secret ->
        conn
      _ ->
        conn
        |> send_resp(401, "")
        |> halt
    end
  end

end
