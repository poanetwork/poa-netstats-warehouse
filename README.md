# POABackend

[![Coverage Status](https://coveralls.io/repos/github/poanetwork/poa-netstats-warehouse/badge.svg?branch=master)](https://coveralls.io/github/poanetwork/poa-netstats-warehouse?branch=master)
[![codecov](https://codecov.io/gh/poanetwork/poa-netstats-warehouse/branch/master/graph/badge.svg)](https://codecov.io/gh/poanetwork/poa-netstats-warehouse)

Storage and data-processing companion for the [poa-netstats-agent](https://github.com/poanetwork/poa-netstats-agent)

## Documentation

In order to build the documentation run

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