defmodule SearchEngineTest do
  use ExUnit.Case
  doctest SearchEngine

  test "greets the world" do
    assert SearchEngine.hello() == :world
  end
end
