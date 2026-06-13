defmodule PhoenixShield.Repo.Migrations.CreateRolesAndPermissionsTables do
  use Ecto.Migration

  def change do
    # Create roles table
    create table(:roles) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:slug])
    create unique_index(:roles, [:name])

    # Create permissions table
    create table(:permissions) do
      add :name, :string, null: false
      add :slug, :string, null: false # Format: "resource:action" e.g., "users:view"
      add :resource, :string, null: false # Group by resource (e.g., "users")
      add :action, :string, null: false   # The action (e.g., "view")
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:permissions, [:slug])
    create index(:permissions, [:resource])
    create index(:permissions, [:action])

    # Join table for roles <-> permissions (many-to-many)
    create table(:role_permissions) do
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :permission_id, references(:permissions, on_delete: :delete_all), null: false
    end

    create unique_index(:role_permissions, [:role_id, :permission_id])

    # Join table for users <-> roles (many-to-many) - assuming users table exists
    create table(:user_roles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role_id, references(:roles, on_delete: :delete_all), null: false
    end

    create unique_index(:user_roles, [:user_id, :role_id])
  end
end
