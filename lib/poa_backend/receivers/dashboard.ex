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

  # we store the last metrics in a ETS table because when a dashboard is connected it can wait a lot until
  # the stats get updated

  @last_metrics_table :last_metrics_table

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

    :ok = set_up_last_metrics_table()

    {:ok, %{clients: []}}
  end

  def metrics_received(metrics, _from, %{clients: clients} = state) do
    :ok = dispatch_metric(metrics, clients)

    {:ok, state}
  end

  def handle_message({:add_client, client}, %{clients: clients} = state) do

    # we send the latest metrics in order to catch up
    stored_metrics = :ets.tab2list(@last_metrics_table)

    for {_, metrics} <- stored_metrics do
      metrics_list = Map.to_list(metrics)
      for {_, metric} <- metrics_list do
        send(client, metric)
      end
    end

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

    save_metrics(metrics)

    :ok
  end

  defp dispatch_metric(metric, clients) do
    dispatch_metric([metric], clients)
  end

  defp save_metrics(metrics) do
    for metric <- metrics do
      case metric.data["type"] do
        "information" ->
          save_last_information(metric)
        "statistics" ->
          save_last_stats(metric)
        _ ->
          :continue
      end
    end

    :ok
  end

  defp save_last_information(%Message{} = metric) do
    case :ets.lookup(@last_metrics_table, metric.agent_id) do
      [] ->
        :ets.insert(@last_metrics_table, {metric.agent_id, %{information: metric}})
      [{_, last_metrics}] ->
        last_metrics = Map.put(last_metrics, :information, metric)
        :ets.insert(@last_metrics_table, {metric.agent_id, last_metrics})
    end

    :ok
  end

  defp save_last_stats(%Message{} = metric) do
    case :ets.lookup(@last_metrics_table, metric.agent_id) do
      [] ->
        :ets.insert(@last_metrics_table, {metric.agent_id, %{stats: metric}})
      [{_, last_metrics}] ->
        last_metrics = Map.put(last_metrics, :stats, metric)
        :ets.insert(@last_metrics_table, {metric.agent_id, last_metrics})
    end

    :ok
  end

  defp set_up_last_metrics_table do
    :ets.new(@last_metrics_table, [:named_table])

    :ok
  end

end