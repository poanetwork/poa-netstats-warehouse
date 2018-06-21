defmodule POABackend.Receivers.DynamoDB do

  @moduledoc """
  This is a Receiver Plugin which stores the received Ethereum Blocks in DynamoDB

  This Receiver needs some data to be put in the config file (_receivers_ section), for example:

      {:dynamodb_receiver, POABackend.Receivers.DynamoDB, [
            scheme: "http://",
            host: "localhost",
            port: 8000,
            access_key_id: "myaccesskeyid",
            secret_access_key: "mysecretaccesskey",
            region: "us-east-1"
            ]}

  * scheme: the scheme type
  * host: host name or url
  * port: the TCP port where the DynamoDB instance is listening
  * access_key_id: the AWS access key
  * secret_access_key: the AWS secret access key
  * region: the AWS region

  __All fields are mandatory__

  """

  use POABackend.Receiver

  alias __MODULE__
  alias POABackend.Protocol.Message

  @pool_name :blocks_dynamodb_worker_pool

  defmodule Worker do
    @moduledoc false

    use GenServer

    alias ExAws.Dynamo

    def init(:args) do
      {:ok, %{}}
    end

    def handle_cast(metric, state) do

      {_, block} = Map.pop(metric.data["body"], "transactions")
      {_, block} = Map.pop(block, "uncles")

      msg_time = DateTime.utc_now |> DateTime.to_iso8601

      message = %{
        msg_type: "block",
        msg_time: msg_time,
        payload: %{block: block}
      }

      Dynamo.put_item("netstat_prod", message)
      |> ExAws.request!

      {:noreply, state}
    end
  end

  def init_receiver(opts) do
    :ok = config(opts)

    {:ok, _pid} = :wpool.start_pool(@pool_name, worker_pool_config(:args))

    {:ok, %{}}
  end

  def metrics_received(metrics, _from, state) do
    for metric <- metrics do
      send_metric(metric)
    end
    {:ok, state}
  end

  def terminate(_) do
    :ok
  end

  defp worker_pool_config(args) do
    [
      overrun_warning: :infinity,
      overrun_handler: {:error_logger, :warning_report},
      workers: 50,
      worker: {DynamoDB.Worker, args}
    ]
  end

  # filtering only block messages
  defp send_metric(%Message{data: %{"type" => "block"}} = metric) do
    :wpool.cast(@pool_name, metric)
  end

  defp send_metric(_) do
    :ok
  end

  @doc false
  defp config(opts) do

    # ExAws

    {_, access_key_id} = List.keyfind(opts, :access_key_id, 0)
    {_, secret_access_key} = List.keyfind(opts, :secret_access_key, 0)

    Application.put_env(:ex_aws, :access_key_id, access_key_id)
    Application.put_env(:ex_aws, :secret_access_key, secret_access_key)

    # ExAwsDynamo

    {_, scheme} = List.keyfind(opts, :scheme, 0)
    {_, host} = List.keyfind(opts, :host, 0)
    {_, port} = List.keyfind(opts, :port, 0)
    {_, region} = List.keyfind(opts, :region, 0)

    config = [scheme: scheme, host: host, port: port, region: region]

    Application.put_env(:ex_aws, :dynamodb, config)
    :ok
  end

end