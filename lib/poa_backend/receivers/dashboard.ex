defmodule POABackend.Receivers.Dashboard do
  
  @moduledoc """
  This is a Receiver Plugin which exposes a Websocket server and sends the metrics to the connected clients

  This Receiver needs some data to be put in the config file (_receivers_ section), for example:

      {:dashboard_receiver, POABackend.Receivers.Dashboard, [
          scheme: :http,
          ws_url: "/ws",
          port: 8181,
          ws_secret: "mywssecret"
          ]}

  * scheme: the scheme type :http or :https
  * ws_url: endpoint for starting websocket connection
  * port: the TCP port where the websocket server will listen
  * ws_secret: the secret string which the clients must put in the "wssecret" header in order to start the connection

  __All fields are mandatory__

  """

  use POABackend.Receiver

  alias __MODULE__
  alias POABackend.Protocol.Message

  defmodule SocketHandler do

    @moduledoc false

    require Logger

    alias POABackend.Protocol.Message

    @behaviour :cowboy_websocket_handler

    def init(_, _req, _opts) do
      {:upgrade, :protocol, :cowboy_websocket}
    end

    def websocket_init(_type, req, %{receiver_id: receiver_id, ws_secret: ws_secret}) do
      case :cowboy_req.parse_header("wssecret", req) do
        {_, ^ws_secret, req} ->
          Logger.info("Websocket connection with dashboard client accepted")

          send(receiver_id, {:add_client, self()})
          {:ok, req, %{receiver_id: receiver_id}}
        {_, _, req} ->
          Logger.info("Websocket connection with dashboard client unauthorized")

          {:shutdown, req}
      end
    end
    
    def websocket_handle(_message, req, state) do
      {:ok, req, state}
    end

    def websocket_info(%Message{} = message, req, state) do
      {:reply, {:text, build_message(message)}, req, state}
    end

    def websocket_terminate(_reason, _req, %{receiver_id: receiver_id}) do
      Logger.warn("Websocket connection with dashboard client lost")

      send(receiver_id, {:remove_client, self()})
      :ok
    end

    defp build_message(%Message{agent_id: agent_id, data: data}) do
      {:ok, message} =
        %{agent_id: agent_id, data: data}
        |> Poison.encode

      message
    end
  end

  defmodule Router do

    @moduledoc false

    use Plug.Router
    
    plug :match
    plug :dispatch
    
    match _ do
      send_resp(conn, 404, "")
    end
  end

  def init_receiver(opts) do
    :ok = start_websockets_server(opts)

    {:ok, %{clients: []}}
  end

  def metrics_received(metrics, _from, %{clients: clients} = state) do
    :ok = dispatch_metric(metrics, clients)

    {:ok, state}
  end

  def handle_message({:add_client, client}, %{clients: clients} = state) do
    {:ok, %{state | clients: [client | clients]}}
  end

  def handle_message({:remove_client, client}, %{clients: clients} = state) do
    {:ok, %{state | clients: List.delete(clients, client)}}
  end

  def handle_inactive(agent_id, %{clients: clients} = state) do
    data = %{"type" => "statistics",
             "body" =>
            %{"active" => false,
              "gasPrice" => nil,
              "hashrate" => 0,
              "mining" => false,
              "peers" => 0,
              "syncing" => nil,
              "uptime" => nil
              }}

    agent_id
    |> Message.new(:ethereum_metrics, :data, data)
    |> dispatch_metric(clients)
    {:ok, state}
  end

  def terminate(_) do
    :ok
  end

  defp start_websockets_server(opts) do
    {_, scheme} = List.keyfind(opts, :scheme, 0)
    {_, ws_url} = List.keyfind(opts, :ws_url, 0)
    {_, port} = List.keyfind(opts, :port, 0)
    {_, ws_secret} = List.keyfind(opts, :ws_secret, 0)

    %{start: {module, function, args}} = Plug.Adapters.Cowboy.child_spec(scheme: scheme, plug: Dashboard.Router, options: [port: port, dispatch: cowboy_dispatch(ws_url, ws_secret)])

    apply(module, function, args)

    :ok
  end

  defp cowboy_dispatch(url, secret) do
    [
      {:_, [
        {url, Dashboard.SocketHandler, %{receiver_id: self(), ws_secret: secret}},
        {:_, Plug.Adapters.Cowboy.Handler, {Dashboard.Router, []}}
      ]}
    ]
  end

  defp dispatch_metric(metrics, clients) when is_list(metrics) do
    for client <- clients do
      for metric <- metrics do
        send(client, metric)
      end
    end

    :ok
  end

  defp dispatch_metric(metric, clients) do
    dispatch_metric([metric], clients)
  end

end