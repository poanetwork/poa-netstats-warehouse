defmodule POABackendTest do
  use ExUnit.Case
  doctest POABackend

  test "greets the world" do
    assert POABackend.hello() == :world
  end
end
