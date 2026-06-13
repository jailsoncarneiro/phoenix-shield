defmodule PhoenixShield.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_shield,
    adapter: Ecto.Adapters.Postgres
end
