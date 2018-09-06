defmodule POABackend.Auth.REST do
  @moduledoc """

  Here we define the REST Endpoints for Authentication/Authorization features in `poa_backend`.
  There are two types of users who will use this Endpoints. 
  - One is the standard user which is associated to one Agent. This user will call only the _/session_ endpoint in order to retrieve a [JWT](https://jwt.io) token
  needed for using the _POA Protocol_ Endpoints. Those users are stored in a Database.
  - The other kind of users are the POA administrators. This users can create _normal_ users using the _/user_ Endpoint, banning tokens, banning users...
  Those Admins are defined in the Config (ie `prod.exs`) file and are loaded when the app starts. This is an example of how the Admins are defined

  ```
        config :poa_backend,
         :admins,
         [
           {"admin1", "password12345678"},
           {"admin2", "password87654321"}
         ]
  ```

  Those Endpoints must run under *__https__* schema

  ## Session Endpoint

  This endpoint will be responsible of returning valid JWT tokens to the Agents if they use a valid user/password for authentication. The form of the endpoint is:

  `POST /session`

  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Basic encodeBase64(username + “:” + password)

  Payload | Value
  -- | --
  JSON | {“agent-id”:”theAgentID”}
  MessagePack | Same as JSON but packed with MessagePack

  Response:

  CODE | Description
  -- | --
  200 | Success: {“token”:”NewToken”}
  401 | Authentication failed
  415 | Unsupported Media Type (only application/json and application/msgpack allowed)

  Example:

  ```
  curl -i -X POST -H "Authorization: Basic Ump1YURzdi06WHY3X0xvQ0FVZVduYmN5" -H "Content-Type: application/json" https://localhost:4003/session --insecure

  HTTP/1.1 200 OK
  server: Cowboy
  date: Fri, 10 Aug 2018 20:25:05 GMT
  content-length: 362
  cache-control: max-age=0, private, must-revalidate

  {"token":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkzNjMwNiwiaWF0IjoxNTMzOTMyNzA2LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6ImI0MzBkNTMwLWExZDYtNDk1Yy1hMjYyLThjNTcxMmM1OTM4YSIsIm5iZiI6MTUzMzkzMjcwNSwic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.E3gqpCxY5wAAhZwcr7vZVLcC7X-bSHcXfX6NgeJc-LMbpcDgJvZgcgYQ-VTIkulb2mWw_Fjc7sXVwYMeIIliMg"}
  ```

  ## Create User Endpoint

  This Endpoint is needed in order to add a new user. Only Admin people can do that.

  `POST /user`

  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Basic encodeBase64(adminname + “:” + password)

  Payload | Value
  -- | --
  JSON | {"agent-id": "AgentId", user-name”:”userName”, "password": "mypassword"}
  MessagePack | Same as JSON but packed with MessagePack

  *_NOTE_* `user-name` and `password` field are optional. If we send only the `user-name` the server will create a random password. If we don't send any value the the server
  will create both, `user-name` and `password`

  Response

  CODE | Description
  -- | --
  200 | Success: {“user”:”Username”, “password”:”mypassword”}
  401 | Authentication failed
  409 | The user already exists
  415 | Unsupported Media Type (only application/json and application/msgpack allowed)

  Example:

  ```
  curl -i -X POST -H "Authorization: Basic YWRtaW4xOnBhc3N3b3JkMTIzNDU2Nzg=" -H "Content-Type: application/json" https://localhost:4003/user --insecure

  HTTP/1.1 200 OK
  server: Cowboy
  date: Fri, 10 Aug 2018 20:40:04 GMT
  content-length: 53
  cache-control: max-age=0, private, must-revalidate

  {"user-name":"vhuevkMy","password":"XkBCEJmuuEzPvy8"}
  ```

  ## List User Endpoint

  This Endpoint is needed in order to list the users in the system. Only Admin people can do that.

  `GET /user`

  HTTP header | Values
  -- | --
  authorization | Basic encodeBase64(adminname + “:” + password)

  Response

  CODE | Description
  -- | --
  200 | Success: A list of users
  401 | Authentication failed

  Example:

  ```
  curl -i -X GET -H "Authorization: Basic YWRtaW4xOnBhc3N3b3JkMTIzNDU2Nzg=" https://localhost:4003/user --insecure

  HTTP/1.1 200 OK
  server: Cowboy
  date: Mon, 03 Sep 2018 16:02:29 GMT
  content-length: 153
  cache-control: max-age=0, private, must-revalidate

  [{"user":"HeeV-EmU","created_at":"2018-09-03T16:02:25.210308","active":true},{"user":"W75AcY8Z","created_at":"2018-09-03T16:02:13.763003","active":true}]
  ```

  The JSON format for a user is:

  ```
  {
    "user":"Username",
    "active":true, # active means it is not banned
    "created_at":"2018-09-03T16:02:25.210308"
  }
  ```

  ## Delete User Endpoint

  This Endpoint is needed in order to delete a user from the system.

  `DELETE /user/:username`

  HTTP header | Values
  -- | --
  authorization | Basic encodeBase64(adminname + “:” + password)

  Response

  CODE | Description
  -- | --
  204 | Success
  401 | Authentication failed
  404 | The user provided doesn't exist in the system

  Example:

  ```
  curl -i -X DELETE -H "Authorization: Basic YWRtaW4xOnBhc3N3b3JkMTIzNDU2Nzg=" https://localhost:4003/user/4uVIqWSf --insecure

  HTTP/1.1 204 No Content
  server: Cowboy
  date: Tue, 04 Sep 2018 13:49:45 GMT
  content-length: 0
  cache-control: max-age=0, private, must-revalidate
  ```

  ## Update User Endpoint

  This Endpoint is needed in order to update a user. Currently only the `active` property can be updated. If a user is set to `active: false` means
  it was banned. We can use this enpoint in order to ban or unban users too.

  `PATCH /user/:username`

  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Basic encodeBase64(adminname + “:” + password)

  Payload | Value
  -- | --
  JSON | {"active" : boolean()}
  MessagePack | Same as JSON but packed with MessagePack

  Response

  CODE | Description
  -- | --
  204 | Success
  401 | Authentication failed
  404 | The user doesn't exist
  415 | Unsupported Media Type (only application/json and application/msgpack allowed)
  422 | Unprocessable entity (the active value is not a boolean)

  Example:

  ```
  curl -i -X PATCH -H "Authorization: Basic YWRtaW4xOnBhc3N3b3JkMTIzNDU2Nzg=" -H "Content-Type: application/json" -d '{"active":false}' https://localhost:4003/user/cZFxFfNT --insecure

  HTTP/1.1 204 No Content
  server: Cowboy
  date: Wed, 05 Sep 2018 13:38:32 GMT
  content-length: 0
  cache-control: max-age=0, private, must-revalidate
  ```

  ## Blacklist Token Endpoint

  This Endpoint is used when we want to ban a single JWT Token (not the entire user) and that will convert that Token invalid. This Endpoint is only called by Admins.

  In order to achive that we have to track the tokens in a Mnesia table. We also have to create a process which cleans the DB every day

  `POST /blacklist/token`

  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Basic encodeBase64(adminname + “:” + password)

  Payload | Value
  -- | --
  JSON | {“token”:”myJWTToken”}
  MessagePack | Same as JSON but packed with MessagePack

  Response

  CODE | Description
  -- | --
  200 | Success
  401 | Authentication failed
  404 | The Token is not valid
  415 | Unsupported Media Type (only application/json and application/msgpack allowed)

  Example:

  ```
  curl -i -d '{"token":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJwb2FfYmFja2VuZCIsImV4cCI6MTUzMzkzNjMwNiwiaWF0IjoxNTMzOTMyNzA2LCJpc3MiOiJwb2FfYmFja2VuZCIsImp0aSI6ImI0MzBkNTMwLWExZDYtNDk1Yy1hMjYyLThjNTcxMmM1OTM4YSIsIm5iZiI6MTUzMzkzMjcwNSwic3ViIjoiUmp1YURzdi0iLCJ0eXAiOiJhY2Nlc3MifQ.E3gqpCxY5wAAhZwcr7vZVLcC7X-bSHcXfX6NgeJc-LMbpcDgJvZgcgYQ-VTIkulb2mWw_Fjc7sXVwYMeIIliMg"}' -X POST -H "Authorization: Basic YWRtaW4xOnBhc3N3b3JkMTIzNDU2Nzg=" -H "Content-Type: application/json" https://localhost:4003/blacklist/token --insecure

  HTTP/1.1 200 OK
  server: Cowboy
  date: Fri, 10 Aug 2018 20:59:25 GMT
  content-length: 0
  cache-control: max-age=0, private, must-revalidate
  ```

  ## Blacklist User Endpoint

  This Endpoint bans a User, that will invalidate its tokens. This Endpoint is only called by Admins.

  In order to achive that we have to track the tokens in a Mnesia table. We also have to create a process which cleans the DB every day

  `POST /blacklist/user`

  HTTP header | Values
  -- | --
  content-type | application/json or application/msgpack
  authorization | Basic encodeBase64(adminname + “:” + password)

  Payload | Value
  -- | --
  JSON | {“user”:”theUserName”}
  MessagePack | Same as JSON but packed with MessagePack

  Response

  CODE | Description
  -- | --
  200 | Success
  401 | Authentication failed
  404 | The user doesn't exist
  415 | Unsupported Media Type (only application/json and application/msgpack allowed)

  Example:

  ```
  curl -i -d '{"user":"vhuevkMy"}' -X POST -H "Authorization: Basic YWRtaW4xOnBhc3N3b3JkMTIzNDU2Nzg=" -H "Content-Type: application/json" https://localhost:4003/blacklist/user --insecure

  HTTP/1.1 200 OK
  server: Cowboy
  date: Fri, 10 Aug 2018 21:55:03 GMT
  content-length: 0
  cache-control: max-age=0, private, must-revalidate
  ```
  """
end