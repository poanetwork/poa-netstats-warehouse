defmodule POABackend.Auth.Router do
  use Plug.Router
  @moduledoc false

  alias POABackend.Auth
  alias POABackend.CustomHandler.REST
  import Plug.Conn

  @token_default_ttl {1, :hour}

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
      ttl = Application.get_env(:poa_backend, :jwt_ttl, @token_default_ttl)
      {:ok, token, _} = POABackend.Auth.Guardian.encode_and_sign(user, %{}, ttl: ttl)

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

  post "/blacklist/user" do
    with {"authorization", "Basic " <> base64} <- List.keyfind(conn.req_headers, "authorization", 0),
         {:ok, decoded64} <- Base.decode64(base64),
         [admin_name, admin_password] <- String.split(decoded64, ":"),
         true <- conn.params["user"] != nil,
         {:ok, :valid} <- Auth.authenticate_admin(admin_name, admin_password)
    do
      case Auth.get_user(conn.params["user"]) do
        nil ->
          send_resp(conn, 404, "")
        user ->
          {:ok, _} = Auth.deactivate_user(user)
          send_resp(conn, 200, "")
      end
    else
      false ->
        conn
          |> send_resp(404, "")
          |> halt
      _error ->
        conn
          |> send_resp(401, "")
          |> halt
    end
  end

  post "/blacklist/token" do
    with {"authorization", "Basic " <> base64} <- List.keyfind(conn.req_headers, "authorization", 0),
         {:ok, decoded64} <- Base.decode64(base64),
         [admin_name, admin_password] <- String.split(decoded64, ":"),
         true <- conn.params["token"] != nil,
         {:ok, :valid} <- Auth.authenticate_admin(admin_name, admin_password)
    do
      case Auth.valid_token?(conn.params["token"]) do
        false ->
          send_resp(conn, 404, "")
        true ->
          {:ok, _} = Auth.create_banned_token(conn.params["token"])
          send_resp(conn, 200, "")
      end
    else
      false ->
        conn
          |> send_resp(404, "")
          |> halt
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