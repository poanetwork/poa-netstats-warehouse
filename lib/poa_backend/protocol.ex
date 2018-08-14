defmodule POABackend.Protocol do
  @moduledoc """

  ## POA Protocol

  This protocol defines the communication between the Agents and the POA Backend.

  ![POA Backend Architecture](./backend_architecture.png)

  ### Basic calls

  Only those calls are allowed:

    * session - In order to generate a token/session for authentication/authorization
    * ping - Ping message
    * data - Specific message for a given receiver. It can be a metric itself or something else
    * bye - Message sent when the Agent wants to close the communication explicitly

  #### session call

  This call is for generate a valid token/session in order to get access to the other calls

  abstract request:

  ```json
  {
    user: String() # user name
    password: String()
  }

  response:

  ```json

  {
    token: String()  # this token must be attached to each call
  }
  ```

  #### ping call

  abstract request:

  ```json
  {
    id: String() # agent id
    token: String() # generated with a valid user/password calling the _session call_
  }
  ```

  response:

  ```json

  {
    result: String()  # “success” or “error”
    payload: String() # optional payload
  }
  ```

  #### data call

  abstract request:

  ```json
  {
    id: String() # agent id
    token: String() # generated with a valid user/password calling the _session call_
    type: String() # data type (for now only ethereum_metrics)
    data: Object() # metric data itself
  }
  ```

  response:

  ```json

  {
    result: String()  # “success” or “error”
    payload: String() # optional payload
  }
  ```

  #### bye call

  abstract request:

  ```json
  {
    id: String() # agent id
    token: String() # generated with a valid user/password calling the _session call_
  }
  ```

  response:

  ```json

  {
    result: String()  # “success” or “error”
    payload: String() # optional payload
  }
  ```

  """
end
