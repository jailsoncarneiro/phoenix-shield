# Carrega as configurações de teste manualmente para garantir que o Postgres tenha todas as chaves
repo_config = [
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: "phoenix_shield_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
]
# Aplica a configuração antes de iniciar qualquer coisa
Application.put_env(:phoenix_shield, PhoenixShield.Repo, repo_config)
Application.put_env(:phoenix_shield, :ecto_repos, [PhoenixShield.Repo])

ExUnit.start()

# Inicia as aplicações necessárias
Application.ensure_all_started(:ecto_sql)
Application.ensure_all_started(:postgrex)

# Inicia o repositório
{:ok, _} = PhoenixShield.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(PhoenixShield.Repo, :manual)
