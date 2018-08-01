defmodule POABackend.Auth.Supervisor do
  @moduledoc false

  alias POABackend.Auth

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    rest_options = Application.get_env(:poa_backend, :auth_rest)
    cowboy_options = [
      port: rest_options[:port],
      keyfile: rest_options[:keyfile],
      certfile: rest_options[:certfile],
      otp_app: :poa_backend
    ]

    children = [
      supervisor(Auth.Repo, []),
      Plug.Adapters.Cowboy.child_spec(scheme: rest_options[:scheme], plug: Auth.Router, options: cowboy_options)
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end