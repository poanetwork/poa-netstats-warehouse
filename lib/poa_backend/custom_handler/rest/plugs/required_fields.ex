defmodule POABackend.CustomHandler.REST.Plugs.RequiredFields do
  @moduledoc false

  @behaviour Plug

  def init(required_fields) do
    required_fields
  end

  def call(conn, required_fields) do
    import Plug.Conn

    case contain_required_fields(conn, required_fields) do
      true ->
        conn
      false ->
        conn
        |> send_resp(422, "")
        |> halt
    end
  end

  defp contain_required_fields(conn, required_fields) do
    required_fields
    |> Enum.all?(&(Map.has_key?(conn.params, &1)))
  end

end
