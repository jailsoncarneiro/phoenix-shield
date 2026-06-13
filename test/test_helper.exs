ExUnit.start()
# Start required applications for testing
Application.ensure_all_started(:ecto_sql)
Application.ensure_all_started(:postgrex)
# Start our repo manually since we removed mod from mix.exs
{:ok, _} = PhoenixShield.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(PhoenixShield.Repo, :manual)
