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

  post "/user" do
    with {"authorization", "Basic " <> base64} <- List.keyfind(conn.req_headers, "authorization", 0),
         {:ok, decoded64} <- Base.decode64(base64),
         [admin_name, admin_password] <- String.split(decoded64, ":"),
         {:ok, :valid} <- Auth.authenticate_admin(admin_name, admin_password)
    do

      user_name = Map.get(conn.params, "user-name", Auth.generate_user_name())
      password = Map.get(conn.params, "password", Auth.generate_password())

      case Auth.valid_user_name?(user_name) do
        true ->
          {:ok, _user} = Auth.create_user(user_name, password)

          {:ok, result} =
            %{:'user-name' => user_name,
              :password => password}
            |> Poison.encode

          send_resp(conn, 200, result)
        false ->
          conn
          |> send_resp(409, "")
          |> halt
      end
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