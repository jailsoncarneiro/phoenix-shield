import Config

# Configure ecto repos for the library
config :phoenix_shield, ecto_repos: [PhoenixShield.Repo]

# Configurações básicas para todos os ambientes
config :logger, level: :info
