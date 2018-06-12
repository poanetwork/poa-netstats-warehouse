defmodule CustomHandlerTest do
  use ExUnit.Case

  defmodule MyCustomHandler do
    use POABackend.CustomHandler
    use GenServer

    # CustomHandler Callbacks

    def child_spec(options) do
      import Supervisor.Spec

      worker(__MODULE__, [options[:caller_pid]])
    end

    # GenServer Callbacks

    def start_link(args) do
      GenServer.start_link(__MODULE__, args, [name: __MODULE__])
    end

    def init(caller_pid) do
      {:ok, caller_pid}
    end

    def handle_info(:hello, caller_pid) do

      # simulate we send something to the receivers

      POABackend.CustomHandler.send_to_receivers(POABackend.Protocol.Message.new())

      send(caller_pid, :world)
      {:noreply, caller_pid}
    end
  end

  test "initialize a custom handler in the supervisor" do

    Application.stop(:poa_backend)
    original_env = Application.get_env(:poa_backend, :custom_handlers)
    Application.put_env(:poa_backend, :custom_handlers, [{:my_ch, MyCustomHandler, [caller_pid: self()]}])
    Application.ensure_all_started(:poa_backend)

    # sending a message and wait for the reply

    CustomHandlerTest.MyCustomHandler
    |> Process.whereis()
    |> send(:hello)

    assert_receive :world, 20_000

    Application.stop(:poa_backend)
    Application.put_env(:poa_backend, :custom_handlers, original_env)
    Application.ensure_all_started(:poa_backend)
  end
end