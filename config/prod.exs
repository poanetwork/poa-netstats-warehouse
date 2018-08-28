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
         # {:dynamodb_receiver, POABackend.Receivers.DynamoDB, [
         #    scheme: "http://",
         #    host: "localhost",
         #    port: 8000,
         #    access_key_id: "BogusAwsAccessKeyId",
         #    secret_access_key: "BogusAwsSecretAccessKey",
         #    region: "us-east-1"
         #    ]}
         {:dashboard_receiver, POABackend.Receivers.Dashboard, [
            scheme: :http,
            ws_url: "/ws",
            port: 8181,
            ws_secret: "wssecret"
            ]},
          {:store_eth_stats, POABackend.Receivers.Eth.Stats, []},
          {:store_system_stats, POABackend.Receivers.System.Stats, []}
       ]

# here we define the type of metrics we accept. We will create a GenStage Producer per each type
config :poa_backend,
       :metrics,
       [
         :ethereum_metrics,
         :networking_metrics,
         :system_metrics
       ]

# here we have to define the relationship between receivers and metric types. The format is {receiver_id, [metric_type]}.
# one receiver can subscribe to multiple metric types
config :poa_backend,
       :subscriptions,
       [
         {:dashboard_receiver, [:ethereum_metrics, :networking_metrics]},
         {:store_eth_stats, [:ethereum_metrics]},
         {:store_system_stats, [:system_metrics]}
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
  secret_key: "LQYmeqQfrphbxUjJltkwH4xnosLc+2S2e8KuYWctMenNY9bmgwnrH8r3ii9FP/8V" # generate your own secret key here!

# this is a list of admins/passwords for authorisation endpoints
config :poa_backend,
       :admins,
       [
         {"admin1", "password12345678"},
         {"admin2", "password87654321"}
       ]

# this will set the expiration in the JWT tokens, the format is `{integer, unit}` where unit is one of:
# `:second` | `:seconds`
# `:minute` | `:minutes`
# `:hour` | `:hours`
# `:week` | `:weeks`
config :poa_backend,
       jwt_ttl: {1, :hour}

config :mnesia,
  dir: 'priv/data/mnesia' # make sure this directory exists!

config :poa_backend, POABackend.Receivers.Repo,
  priv: "priv/receivers",
  adapter: Ecto.Adapters.Postgres,
  database: "poabackend_stats",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"