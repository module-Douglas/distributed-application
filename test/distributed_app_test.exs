defmodule DistributedAppTest do
  use ExUnit.Case
  doctest DistributedApp

  test "greets the world" do
    assert DistributedApp.hello() == :world
  end
end
