defmodule POABackend.CustomHandler.REST do
  use POABackend.CustomHandler

  @moduledoc """
  This module implements the REST Custom Handler over HTTP/1.1.

  # Plugin Architecture

  This plugin involves many processes. When the `POABackend.CustomHandler.Supervisor` calls the
  `child_spec/2` function it will create its own supervision tree under that supervisor

  ![REST plugin Architecture](./REST_architecture.png)

  - `POABackend.CustomHandler.REST.Supervisor` is the main supervisor. It is in charge of supervise its three
  children.
  - The `Ranch/Cowboy` branch is managed by Ranch and Cowboy apps. They are in charge of expose the REST endpoints on top
  of http.
  - The Registry is an Elixir Registry in charge of track/untrack Activity Monitor Servers, created by the next child
  - `POABackend.CustomHandler.REST.Monitor.Supervisor` is a Supervisor with `:simple_one_for_one` strategy. It will start
  dynamically `GenServer`'s implemented by `POABackend.CustomHandler.REST.Monitor.Server` module.

  # REST endpoints

  This Pluting also defines the endpoints needed to use the POA Protocol.

  __All the endpoints accept pure JSON or [MessagePack](https://msgpack.org/) formats__

  ## _session_ endpoint

  In order to get valid access to the rest of the endpoint you will need a JWT token. In order to get it check [here](POABackend.Auth.REST.html#module-session-endpoint)

  ## _ping_ endpoint

  ```
  POST /ping
  ```

  Headers:
  
  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Bearer jwtToken

  payload:

  ```json
    JSON:

    {
      id: String() # agent id
    }

    MessagePack:
  
    Same format as JSON but packed thru MessagePack library
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ and __application/msgpack__ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID"}' -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkyNDc4NCwiaWF0IjoxNTMzOTIxMTg0LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6IjFlM2U0MTU0LWJiNDMtNDY0MS04ZGFmLTIxNjRlOTFmMTU4YiIsIm5iZiI6MTUzMzkyMTE4Mywic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.SqE48FXKhN7Y7aAsipFwvIAqetyhVJGwARMEwNwCXSK-QnXZdu3f2xkHDrXBsf1L1IlhTwg78Y-RiKrgepV34Q" -X POST http://localhost:4002/ping

  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying ::1...
  * TCP_NODELAY set
  * Connection failed
  * connect to ::1 port 4002 failed: Connection refused
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /ping HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkyNDc4NCwiaWF0IjoxNTMzOTIxMTg0LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6IjFlM2U0MTU0LWJiNDMtNDY0MS04ZGFmLTIxNjRlOTFmMTU4YiIsIm5iZiI6MTUzMzkyMTE4Mywic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.SqE48FXKhN7Y7aAsipFwvIAqetyhVJGwARMEwNwCXSK-QnXZdu3f2xkHDrXBsf1L1IlhTwg78Y-RiKrgepV34Q
  > Content-Length: 16
  >
  * upload completely sent off: 16 out of 16 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Fri, 10 Aug 2018 17:14:33 GMT
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

  Headers:
  
  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Bearer jwtToken

  payload:

  ```json
    JSON:

    {
      id: String() # agent id
      type: String() # data type (for now only ethereum_metrics)
      data: Object() # metric data itself
    }

    MessagePack:

    Same format as JSON but packed thru MessagePack library
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ and __application/msgpack__ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID", "type":"ethereum_metrics", "data":{"hello":"world"}}' -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkyNDc4NCwiaWF0IjoxNTMzOTIxMTg0LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6IjFlM2U0MTU0LWJiNDMtNDY0MS04ZGFmLTIxNjRlOTFmMTU4YiIsIm5iZiI6MTUzMzkyMTE4Mywic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.SqE48FXKhN7Y7aAsipFwvIAqetyhVJGwARMEwNwCXSK-QnXZdu3f2xkHDrXBsf1L1IlhTwg78Y-RiKrgepV34Q" -X POST http://localhost:4002/data

  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying ::1...
  * TCP_NODELAY set
  * Connection failed
  * connect to ::1 port 4002 failed: Connection refused
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /data HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkyNDc4NCwiaWF0IjoxNTMzOTIxMTg0LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6IjFlM2U0MTU0LWJiNDMtNDY0MS04ZGFmLTIxNjRlOTFmMTU4YiIsIm5iZiI6MTUzMzkyMTE4Mywic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.SqE48FXKhN7Y7aAsipFwvIAqetyhVJGwARMEwNwCXSK-QnXZdu3f2xkHDrXBsf1L1IlhTwg78Y-RiKrgepV34Q
  > Content-Length: 69
  >
  * upload completely sent off: 69 out of 69 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Fri, 10 Aug 2018 17:17:34 GMT
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

  Headers:
  
  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Bearer jwtToken

  payload:

  ```json
    JSON:

    {
      id: String() # agent id
    }

    MessagePack:

    Same format as JSON but packed thru MessagePack library
  ```

  responses:

  | Code | Description |
  | :--- | :---------- |
  | 200  | Success _{"result":"success"}_ |
  | 401  | Unauthorized |
  | 415  | Unsupported Media Type (only _application/json_ and __application/msgpack__ allowed) |
  | 422  | Unprocessable Entity. Required fields missing|

  Example:

  ```
  curl -v -d '{"id":"agentID"}' -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkyNDc4NCwiaWF0IjoxNTMzOTIxMTg0LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6IjFlM2U0MTU0LWJiNDMtNDY0MS04ZGFmLTIxNjRlOTFmMTU4YiIsIm5iZiI6MTUzMzkyMTE4Mywic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.SqE48FXKhN7Y7aAsipFwvIAqetyhVJGwARMEwNwCXSK-QnXZdu3f2xkHDrXBsf1L1IlhTwg78Y-RiKrgepV34Q" -X POST http://localhost:4002/bye
  
  Note: Unnecessary use of -X or --request, POST is already inferred.
  *   Trying ::1...
  * TCP_NODELAY set
  * Connection failed
  * connect to ::1 port 4002 failed: Connection refused
  *   Trying 127.0.0.1...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 4002 (#0)
  > POST /bye HTTP/1.1
  > Host: localhost:4002
  > User-Agent: curl/7.53.1
  > Accept: */*
  > Content-Type: application/json
  > Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkyNDc4NCwiaWF0IjoxNTMzOTIxMTg0LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6IjFlM2U0MTU0LWJiNDMtNDY0MS04ZGFmLTIxNjRlOTFmMTU4YiIsIm5iZiI6MTUzMzkyMTE4Mywic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.SqE48FXKhN7Y7aAsipFwvIAqetyhVJGwARMEwNwCXSK-QnXZdu3f2xkHDrXBsf1L1IlhTwg78Y-RiKrgepV34Q
  > Content-Length: 16
  >
  * upload completely sent off: 16 out of 16 bytes
  < HTTP/1.1 200 OK
  < server: Cowboy
  < date: Fri, 10 Aug 2018 17:19:24 GMT
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
    alias POABackend.Protocol.DataType
    alias POABackend.Protocol.Message

    plug REST.Plugs.ContentType, ["application/json", "application/msgpack"]
    plug Plug.Parsers, parsers: [Msgpax.PlugParser, :json], pass: ["application/msgpack", "application/json"], json_decoder: Poison
    plug REST.Plugs.RequiredFields, ~w(id)
    plug REST.Plugs.Authorization
    plug :match
    plug :dispatch

    post "/ping" do
      :ok = REST.ping_monitor(conn.params["id"])

      conn
      |> put_resp_content_type("application/json")
      |> send_success_resp()
    end

    post "/data" do
      conn = REST.Plugs.RequiredFields.call(conn, ~w(type data))

      with false <- conn.halted,
           true <- is_map(conn.params["data"]),
           true <- DataType.valid?(conn.params["type"])
      do

        type = String.to_existing_atom(conn.params["type"])

        # sending the data to the receivers
        conn.params["id"]
        |> Message.new(type, :data, conn.params["data"])
        |> POABackend.CustomHandler.send_to_receivers()

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

  @doc """
  This function will initialize an Activity Monitor Server for a given Agent ID if it doesn't
  exist already. If it exist this function will send a ping message to the Monitor Server in order to
  restart the timeout countdown.

  The Activity Monitor Server is a `GenServer` which will be initialized under the
  `POABackend.CustomHandler.REST.Monitor.Supervisor` supervisor.
  """
  def ping_monitor(agent_id) when is_binary(agent_id) do
    case Registry.lookup(:rest_activity_monitor_registry, agent_id) do
      [{pid, _}] ->
        GenServer.cast(pid, :ping)
      [] ->
        {:ok, _} = start_monitor(agent_id)
    end

    :ok
  end

  @doc false
  def start_monitor(agent_id) when is_binary(agent_id) do
    Supervisor.start_child(POABackend.CustomHandler.REST.Monitor.Supervisor, [agent_id])
  end

  # Custom Handler Callbacks

  @doc false
  def child_spec(options) do
    POABackend.CustomHandler.REST.Supervisor.child_spec(options)
  end

end