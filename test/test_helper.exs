import Config
# Load test configuration
if Mix.env() == :test do
  Mix.load_config("config/test.exs")
end
ExUnit.start()
# Start required applications for testing
Application.ensure_all_started(:ecto_sql)
Application.ensure_all_started(:postgrex)
# Explicitly set repo config from test.exs
repo_config = [
  username: System.get_env("DB_USERNAME", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  hostname: System.get_env("DB_HOSTNAME", "localhost"),
  database: "phoenix_shield_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
]
Application.put_all_env([{:phoenix_shield, PhoenixShield.Repo, repo_config}])
# Start our repo manually
{:ok, _} = PhoenixShield.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(PhoenixShield.Repo, :manual)
