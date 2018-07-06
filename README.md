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

## Run Tests

In order to run the tests we have to run the command

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