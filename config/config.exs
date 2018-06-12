use Mix.Config

config :plug, :statuses, %{

  401 => "Unauthorized",
  415 => "Unsupported Media Type",
  422 => "Unprocessable Entity"
}

import_config "#{Mix.env}.exs"
