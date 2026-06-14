defmodule PhoenixShield.PermissionsDiscovery do
  @moduledoc """
  Discovers permissions from LiveViews, Controllers and Contexts in the application.
  Scans modules for @permission annotations and generates the necessary permission slugs.
  """

  @doc """
  Scans all loaded modules for permissions and returns a list of all discovered permissions.
  """
  def discover_all_permissions do
    # Get all loaded modules
    :code.all_loaded()
    |> Enum.filter(&is_phoenix_module?/1)
    |> Enum.flat_map(&extract_permissions_from_module/1)
    |> Enum.uniq()
  end

  @doc """
  Syncs discovered permissions with the database - creates any missing permissions.
  """
  def sync_permissions_with_db do
    discovered = discover_all_permissions()

    Enum.each(discovered, fn {slug, name, description} ->
      # Check if permission exists, if not create it
      repo = PhoenixShield.Config.repo()
      case repo.get_by(PhoenixShield.Permission, slug: slug) do
        nil ->
          # Split slug into resource and action
          [resource, action] = String.split(slug, ":")

          %PhoenixShield.Permission{}
          |> PhoenixShield.Permission.changeset(%{
            slug: slug,
            name: name,
            resource: resource,
            action: action,
            description: description
          })
          |> repo.insert!()

        _existing ->
          :ok # Permission already exists
      end
    end)
  end

  defp is_phoenix_module?(module) do
    # Check if module is a LiveView, Controller or Context
    module_str = inspect(module)
    String.contains?(module_str, "LiveView") or
    String.contains?(module_str, "Controller") or
    String.contains?(module_str, "Web.") or
    String.contains?(module_str, "Contexts.")
  end

  defp extract_permissions_from_module(module) do
    # Look for @permission module attributes
    if function_exported?(module, :__attributes__, 0) do
      module.__attributes__()
      |> Keyword.get_values(:permission)
      |> Enum.map(fn {slug, name, description} -> {slug, name, description} end)
    else
      []
    end
  end

  @doc """
  Macro to add permissions to a LiveView or Controller.
  Usage:

      @permission "users:view", "View users", "Allows viewing user list"
      @permission "users:create", "Create users", "Allows creating new users"
  """
  defmacro permission(slug, name, description) do
    quote bind_quoted: [slug: slug, name: name, description: description] do
      Module.register_attribute(__MODULE__, :permission, accumulate: true)
      @permission {slug, name, description}
    end
  end

  defmacro permission(slug, name) do
    quote bind_quoted: [slug: slug, name: name] do
      Module.register_attribute(__MODULE__, :permission, accumulate: true)
      @permission {slug, name, ""}
    end
  end
end
