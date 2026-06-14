defmodule PhoenixShield.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixShieldWeb.Telemetry,
      PhoenixShield.Repo,
      {DNSCluster, query: Application.get_env(:phoenix_shield, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixShield.PubSub},
      # Start a worker by calling: PhoenixShield.Worker.start_link(arg)
      # {PhoenixShield.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixShieldWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixShield.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixShieldWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
