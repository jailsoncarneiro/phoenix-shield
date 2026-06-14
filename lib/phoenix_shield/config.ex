defmodule PhoenixShield.Config do
  @moduledoc """
  Configuration module for PhoenixShield. Retrieves application environment variables.
  """

  @doc """
  Gets the configured Repo from the host application.
  Defaults to PhoenixShield.Repo if not configured.
  """
  def repo do
    Application.get_env(:phoenix_shield, :repo, PhoenixShield.Repo)
  end

  @doc """
  Gets the configured User schema from the host application.
  Defaults to PhoenixShield.User if not configured.
  """
  def user_schema do
    Application.get_env(:phoenix_shield, :user_schema, PhoenixShield.User)
  end
end
