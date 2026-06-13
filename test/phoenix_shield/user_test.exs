defmodule PhoenixShield.UserTest do
  use ExUnit.Case, async: true

  test "PhoenixShield.User is available and defines the __using__ macro" do
    # Verify the module exists and has the macro
    assert function_exported?(PhoenixShield.User, :__using__, 1)
  end
end
