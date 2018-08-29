# POABackend

[![Coverage Status](https://coveralls.io/repos/github/poanetwork/poa-netstats-warehouse/badge.svg?branch=master)](https://coveralls.io/github/poanetwork/poa-netstats-warehouse?branch=master)
[![codecov](https://codecov.io/gh/poanetwork/poa-netstats-warehouse/branch/master/graph/badge.svg)](https://codecov.io/gh/poanetwork/poa-netstats-warehouse)

Storage and data-processing companion for the [poa-netstats-agent](https://github.com/poanetwork/poa-netstats-agent)

## Documentation

- [Initial Architecture](pages/initial_architecture.md)
- You can find the online documentation [here](https://rawgit.com/poanetwork/poa-netstats-warehouse/master/doc/index.html)

Or you can build the documenation locally running

```
mix deps.get
mix docs
```

That command will create a `doc/` folder with the actual Documentation.

## Configuring Databases for first time

`POABackend` uses many Databases. For Authentication we use [Mnesia](http://erlang.org/doc/man/mnesia.html) as a local database and for some receivers which require storage we use Postgres. All databases are managed on top of [Ecto](https://hexdocs.pm/ecto/Ecto.html) a widly used database wrapper for Elixir projects.

For this reason we have to set the databases before running the `POABackend` for the first time.

- Auth Database (Mnesia): Setting up Mnesia is easy since it is working localy and is built in the Erlang Virtual Machine. We only have to say "where" we are going to store the database's files. In order to do that we have to add the configuration to the config file (`prod.exs` or `test.exs` depending if you want to run tests or production)

```
config :mnesia,
  dir: 'your/local/path' # make sure this directory exists!
```

- Receivers Database (Postgres): This is a little more complex than Mnesia. We need a Postgres instance running somewhere and we have to add the config to the config files

```
config :poa_backend, POABackend.Receivers.Repo,
  priv: "priv/receivers", # this value is not changed
  adapter: Ecto.Adapters.Postgres,
  database: "poabackend_stats",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
```

The important fields here are `database`, `username`, `password` and `hostname`. The rest of values must remain exactly as the example.

Once we have set the database configuration we have to create and migrate the databases, in order to do that we should be in the root of the project and run:

- for production

```
MIX_ENV=prod mix ecto.create
MIX_ENV=prod mix ecto.migrate
```

- for test

```
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate
```

Now the environment is ready for running `POABackend`

## Run Tests

The first time you run the tests you will need having the Database's environment set up. Check the previous section and set the configuration in the `config/test.exs` file.

Once the environment is set. We can run the tests with:

```
mix test
```

`POABackend` comes also with a code analysis tool [Credo](https://github.com/rrrene/credo) and a types checker tool [Dialyxir](https://github.com/jeremyjh/dialyxir). In order to run them we have to run

```
mix credo
mix dialyzer
```

## Building & Deploying an Executable

To build an executable you'll need Elixir 1.6 (and Erlang/OTP 20).

1. Once you have a copy of this repository configure the backend for production in the file `config/prod.exs`.
2. An example configuration can be found in the current `config/prod.exs`.
3. Do a `mix deps.get` to fetch, among other dependencies, the tooling for building server executables.
4. A `env MIX_ENV=prod mix release --name=poa_backend --env=prod` will assemble an executable.

A resulting artifact resides at `_build/prod/rel/poa_backend/releases/0.1.0/poa_backend.tar.gz` which you can move to a remote host.
Use `tar xfz` then `bin/poa_agent start` (`bin/poa_agent stop` will stop the server cleanly).

If you want to run it on the local host then the procedure is as simple as: `_build/prod/rel/poa_backend/bin/poa_backend`.

**Note:** executables must be built on the platform (OS and architecture) they are destined for under the project's current configuration.
Other options are possible (see `https://hexdocs.pm/distillery/getting-started.html`).