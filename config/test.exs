use Mix.Config

config :poa_backend,
       :secret, "mysecret"

# configuration for custom handlers. The format is {custom_handler_name, module, args}
config :poa_backend, 
       :custom_handlers,
       [
         {:rest_custom_handler, POABackend.CustomHandler.REST, [scheme: :http, port: 4002]}
       ]

# configuration of the Receivers we want to start. The format is {id, module, args}
config :poa_backend,
       :receivers,
       [
         {:dashboard_receiver, POABackend.Receivers.Dashboard, [
            scheme: :http,
            ws_url: "/ws",
            port: 8181,
            ws_secret: "mywssecret"
            ]}
       ]

# here we define the type of metrics we accept. We will create a GenStage Producer per each type
config :poa_backend,
       :metrics,
       [
         :ethereum_metrics
       ]

# here we have to define the relationship between receivers and metric types. The format is {receiver_id, [metric_type]}.
# one receiver can subscribe to multiple metric types
config :poa_backend,
       :subscriptions,
       [
         {:dashboard_receiver, [:ethereum_metrics]}
       ]

# here we define the configuration for the Authorisation endpoint
config :poa_backend,
       :auth_rest,
       [
          {:scheme, :https},
          {:port, 4003},
          {:keyfile, "priv/keys/localhost.key"},
          {:certfile, "priv/keys/localhost.cert"}
       ]

config :poa_backend, POABackend.Auth.Guardian,
  issuer: "poa_backend",
  secret_key: "LQYmeqQfrphbxUjJltkwH4xnosLc+2S2e8KuYWctMenNY9bmgwnrH8r3ii9FP/8V"

config :mnesia,
  dir: '_build/test' # make sure this directory exists!
