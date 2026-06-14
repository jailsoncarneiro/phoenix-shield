defmodule PhoenixShield.ConfigTest do
  use ExUnit.Case, async: true
  alias PhoenixShield.Config

  test "repo/0 returns the configured repo, defaulting to PhoenixShield.Repo" do
    # Test default value
    assert Config.repo() == PhoenixShield.Repo

    # Test custom configuration
    Application.put_env(:phoenix_shield, :repo, MyApp.CustomRepo)
    assert Config.repo() == MyApp.CustomRepo

    # Clean up
    Application.delete_env(:phoenix_shield, :repo)
  end

  test "user_schema/0 returns the configured user schema, defaulting to PhoenixShield.User" do
    # Test default value
    assert Config.user_schema() == PhoenixShield.User

    # Test custom configuration
    Application.put_env(:phoenix_shield, :user_schema, MyApp.Accounts.User)
    assert Config.user_schema() == MyApp.Accounts.User

    # Clean up
    Application.delete_env(:phoenix_shield, :user_schema)
  end
end
