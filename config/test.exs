use Mix.Config

config :poa_backend,
       :secret, "mysecret"

# configuration for custom handlers. The format is {custom_handler_name, module, args}
config :poa_backend, 
       :custom_handlers,
       [
         {:rest_custom_handler, POABackend.CustomHandler.REST, [scheme: :http, port: 4002]}
       ]