defmodule POABackend.Auth.Router do
  use Plug.Router
  @moduledoc false

  alias POABackend.Auth
  alias POABackend.CustomHandler.REST
  import Plug.Conn

  plug REST.Plugs.Accept, ["application/json", "application/msgpack"]
  plug Plug.Parsers, parsers: [Msgpax.PlugParser, :json], pass: ["application/msgpack", "application/json"], json_decoder: Poison
  plug :match
  plug :dispatch

  post "/session" do
    with {"authorization", "Basic " <> base64} <- List.keyfind(conn.req_headers, "authorization", 0),
         {:ok, decoded64} <- Base.decode64(base64),
         [user_name, password] <- String.split(decoded64, ":"),
         {:ok, user} <- Auth.authenticate_user(user_name, password)
    do
      {:ok, token, _} = POABackend.Auth.Guardian.encode_and_sign(user)

      {:ok, result} =
        %{token: token}
        |> Poison.encode

      send_resp(conn, 200, result)
    else
      _error ->
        conn
          |> send_resp(401, "")
          |> halt
    end
  end

  match _ do
    send_resp(conn, 404, "")
  end

end