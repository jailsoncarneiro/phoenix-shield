defmodule Mix.Tasks.Shield.Install do
  @moduledoc """
  Installs PhoenixShield into the host application. Copies all necessary migrations to the host's priv/repo/migrations folder.

  Usage:

      mix shield.install
  """
  use Mix.Task

  @shortdoc "Installs PhoenixShield migrations into the host application"
  def run(_args) do
    # Path to our library's migrations
    source_migrations = Path.join(:code.priv_dir(:phoenix_shield), "repo/migrations")

    # Path to the host app's migrations
    target_migrations = Path.join(File.cwd!(), "priv/repo/migrations")

    # Create target directory if it doesn't exist
    File.mkdir_p!(target_migrations)

    # Copy all migration files
    case File.ls(source_migrations) do
      {:ok, files} ->
        Enum.each(files, fn file ->
          source = Path.join(source_migrations, file)
          target = Path.join(target_migrations, file)

          if File.exists?(target) do
            Mix.shell().info([:yellow, "Migration #{file} already exists, skipping..."])
          else
            File.cp!(source, target)
            Mix.shell().info([:green, "✓ Copied migration: #{file}"])
          end
        end)

        Mix.shell().info("")
        Mix.shell().info([:green, "PhoenixShield installed successfully!"])
        Mix.shell().info("Run `mix ecto.migrate` to create all the necessary database tables.")

      {:error, reason} ->
        Mix.shell().error([:red, "Failed to read migrations directory: #{inspect(reason)}"])
    end
  end
end
