defmodule POABackend.Receiver do
  
  @moduledoc """
  Defines a Receiver Plugin.

  A Receiver plugin will run in an independent process and will run the `metrics_received/3`
  function every time it receives a metric from the agents.

  `POABackend` app reads the Receivers configuration from the `config.exs` file when bootstrap and will create a
  process per each one of them. That configuration is referenced by :receivers key.

      config :poa_backend,
         :receivers,
         [
           {name, module, args}
         ]

  for example

      config :poa_backend,
         :receivers,
         [
           {:my_receiver, POABackend.Receivers.MyReceiver, [host: "localhost", port: 1234]}
         ]

  `name`, `module` and `args` must be defined in the configuration file.

  - `name`: Name for the new created process. Must be unique
  - `module`: Module which implements the Receiver behaviour
  - `args`: Initial args which will be passed to the `init_receiver/1` function

  The Receiver's mechanism is built on top of [GenStage](https://hexdocs.pm/gen_stage/GenStage.html). Receivers are Consumers (sinks) and they must
  be subscribed to one or more Producers. The Producers are the Metric types (i.e. `ethereum_metrics`) and are defined in the config file too:

      config :poa_backend,
             :metrics,
             [
               :ethereum_metrics
             ]

  In order to work properly we have to define in the configuration file the relation between the Receiver
  and the Metric types it wants to receive. 

      config :poa_backend,
           :subscriptions,
           [
             {receiver_name, [metric_type1, metric_type2]}
           ]

  for example

      config :poa_backend,
             :subscriptions,
             [
               # {:my_receiver, [:ethereum_metrics]}
             ]

  ## Implementing A Receiver Plugin

  In order to implement your Receiver Plugin you must implement 3 functions.

  - `init_receiver/1`: Called only once when the process starts
  - `metrics_received/3`: This function is called eveytime the Producer (metric type) receives a message.
  - `handle_message/1`: This is called when the Receiver process receives an Erlang message
  - `terminate/1`: Called just before stopping the process

  This is a simple example of custom Receiver Plugin

      defmodule POABackend.Receivers.MyReceiver do
        use POABackend.Receiver

        def init_receiver(_args) do
          {:ok, :no_state}
        end

        def metrics_received(metrics, from, state) do
          for metric <- metrics do
            IO.puts "metric received"
          end
          {:ok, state}
        end

        def terminate(_state) do
          :ok
        end

      end

  """

  @doc """
    A callback executed when the Receiver Plugin starts.
    The argument is retrieved from the configuration file when the Receiver is defined
    It must return `{:ok, state}`, that `state` will be keept as in `GenServer` and can be
    retrieved in the `metrics_received/3` function.
  """
  @callback init_receiver(args :: term()) :: {:ok, state :: any()}


  @doc """
    This callback will be called every time a message to the subscribed metric type arrives. It must
    return the tuple `{:ok, state}`
  """
  @callback metrics_received(metrics :: [term()], from :: pid(), state :: any()) :: {:ok, state :: any()}

  @doc """
    In this callback is called when the Receiver process receives an erlang message.

    It must return `{:ok, state}`.
  """
  @callback handle_message(msg :: any(), state :: any()) :: {:ok, state :: any()}

  @doc """
    This callback is called just before the Process goes down. This is a good place for closing connections.
  """
  @callback terminate(state :: term()) :: term()

  defmacro __using__(_opt) do
    quote do
      use GenStage

      @behaviour POABackend.Receiver

      @doc false
      def start_link(%{name: name} = state) do
        GenStage.start_link(__MODULE__, state, name: name)
      end

      @doc false
      def init(state) do
        {:ok, internal_state} = init_receiver(state.args)

        {:consumer, Map.put(state, :internal_state, internal_state), subscribe_to: state.subscribe_to}
      end

      @doc false
      def handle_events(events, from, state) do

        {:ok, internal_state} = metrics_received(events, from, state.internal_state)

        {:noreply, [], %{state | internal_state: internal_state}}
      end

      @doc false
      def handle_info(msg, state) do
        {:ok, internal_state} = handle_message(msg, state.internal_state)
        {:noreply, [], %{state | internal_state: internal_state}}
      end

      @doc false
      def terminate(_reason, state) do
        terminate(state)
      end
    end
  end

end
