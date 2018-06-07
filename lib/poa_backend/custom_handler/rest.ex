defmodule POABackend.CustomHandler.REST do
  use POABackend.CustomHandler

  @moduledoc """
  This module implements the REST Custom Handler over HTTP/1.1.

  It defines the endpoints needed to use the POA Protocol.

  ## _hello_ endpoint

  ```
  POST /hello
  ```

  request:

  ```
  Headers: {"content-type", "application/json"}
  payload:
    {
      id: String() # agent id
      secret: String() # secret string for authentication/authorisation
      data: Object() # optional data for receivers (i.e. Dashboard needs specific data here)
    }
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID", "secret":"mysecret", "data":"{}"}' -H "Content-Type: application/json" -X POST http://localhost:4002/hello

  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /hello HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Content-Length: 50
  >
  * upload completely sent off: 50 out of 50 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Thu, 07 Jun 2018 20:33:06 GMT
  < content-length: 20
  < cache-control: max-age=0, private, must-revalidate
  < content-type: application/json; charset=utf-8
  <
  * Connection #0 to host localhost left intact
  {"result":"success"}
  ```

  ## _ping_ endpoint

  ```
  POST /ping
  ```

  request:

  ```
  Headers: {"content-type", "application/json"}
  payload:
    {
      id: String() # agent id
      secret: String() # secret string for authentication/authorisation
    }
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID", "secret":"mysecret"}' -H "Content-Type: application/json" -X POST http://localhost:4002/ping

  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /ping HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Content-Length: 37
  >
  * upload completely sent off: 37 out of 37 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Fri, 08 Jun 2018 13:27:58 GMT
  < content-length: 20
  < cache-control: max-age=0, private, must-revalidate
  < content-type: application/json; charset=utf-8
  <
  * Connection #0 to host localhost left intact
  {"result":"success"}
  ```

  ## _latency_ endpoint

  ```
  POST /latency
  ```

  request:

  ```
  Headers: {"content-type", "application/json"}
  payload:
    {
      id: String() # agent id
      secret: String() # secret string for authentication/authorisation
      latency: Float() # latency in milliseconds
    }
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID", "secret":"mysecret", "latency":22.0}' -H "Content-Type: application/json" -X POST http://localhost:4002/latency

  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /latency HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Content-Length: 53
  >
  * upload completely sent off: 53 out of 53 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Fri, 08 Jun 2018 15:02:09 GMT
  < content-length: 20
  < cache-control: max-age=0, private, must-revalidate
  < content-type: application/json; charset=utf-8
  <
  * Connection #0 to host localhost left intact
  {"result":"success"}
  ```

  ## _data_ endpoint

  ```
  POST /data
  ```

  request:

  ```
  Headers: {"content-type", "application/json"}
  payload:
    {
      id: String() # agent id
      secret: String() # secret string for authentication/authorisation
      type: String() # data type (for now only ethereum_metrics)
      data: Object() # metric data itself
    }
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID", "secret":"mysecret", "type":"ethereum_metrics", "data":{"hello":"world"}}' -H "Content-Type: application/json" -X POST http://localhost:4002/data

  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /data HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Content-Length: 90
  >
  * upload completely sent off: 90 out of 90 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Fri, 08 Jun 2018 16:02:22 GMT
  < content-length: 20
  < cache-control: max-age=0, private, must-revalidate
  < content-type: application/json; charset=utf-8
  <
  * Connection #0 to host localhost left intact
  {"result":"success"}
  ```

  ## _bye_ endpoint

  ```
  POST /bye
  ```

  request:

  ```
  Headers: {"content-type", "application/json"}
  payload:
    {
      id: String() # agent id
      secret: String() # secret string for authentication/authorisation
    }
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID", "secret":"mysecret"}' -H "Content-Type: application/json" -X POST http://localhost:4002/bye

  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /bye HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Content-Length: 37
  >
  * upload completely sent off: 37 out of 37 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Fri, 08 Jun 2018 15:49:05 GMT
  < content-length: 20
  < cache-control: max-age=0, private, must-revalidate
  < content-type: application/json; charset=utf-8
  <
  * Connection #0 to host localhost left intact
  {"result":"success"}

  ```
  """

  defmodule Router do
    use Plug.Router
    @moduledoc false

    alias POABackend.CustomHandler.REST

    plug REST.AcceptPlug, "application/json"
    plug Plug.Parsers, parsers: [:json], json_decoder: Poison
    plug REST.RequiredFieldsPlug, ~w(id secret)
    plug REST.AuthorizationPlug
    plug :match
    plug :dispatch

    post "/hello" do
      conn
      |> put_resp_content_type("application/json")
      |> send_success_resp()
    end

    post "/ping" do
      conn
      |> put_resp_content_type("application/json")
      |> send_success_resp()
    end

    post "/latency" do
      conn = REST.RequiredFieldsPlug.call(conn, ~w(latency))

      with false <- conn.halted,
           true <- is_float(conn.params["latency"])
      do
        conn
          |> put_resp_content_type("application/json")
          |> send_success_resp()
      else
        false ->
          conn
          |> send_resp(422, "")
          |> halt
        true -> 
          conn
      end
    end

    post "/data" do
      conn = REST.RequiredFieldsPlug.call(conn, ~w(type data))

      with false <- conn.halted,
           true <- is_map(conn.params["data"])
      do
        conn
          |> put_resp_content_type("application/json")
          |> send_success_resp()
      else
        false ->
          conn
          |> send_resp(422, "")
          |> halt
        true -> 
          conn
      end
    end

    post "/bye" do
      conn
      |> put_resp_content_type("application/json")
      |> send_success_resp()
    end

    match _ do
      send_resp(conn, 404, "")
    end

    defp send_success_resp(conn) do
      send_resp(conn, 200, success_result())
    end

    defp success_result() do
      {:ok, result} = 
        %{result: "success"}
        |> Poison.encode

      result
    end
  end

  # Custom Handler Callbacks

  def child_spec(options) do
    Plug.Adapters.Cowboy.child_spec(scheme: options[:scheme], plug: POABackend.CustomHandler.REST.Router, options: [port: options[:port]])
  end

end