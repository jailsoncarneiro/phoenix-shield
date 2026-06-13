defmodule PhoenixShield.User do
  @moduledoc """
  A macro module that injects PhoenixShield's roles association and helper functions
  into the host application's User schema.

  ## Usage
      **Important:** `use PhoenixShield.User` MUST be placed INSIDE the `schema do ... end` block, because it injects Ecto's `many_to_many` association which requires a schema context.

      defmodule MyApp.Accounts.User do
        use Ecto.Schema

        schema "users" do
          use PhoenixShield.User
          # ... your existing fields
        end
      end
  """
  defmacro __using__(_opts) do
    quote bind_quoted: [], unquote: true do
      import Ecto.Schema
      alias PhoenixShield.Config
      alias PhoenixShield.Role

      # Inject the many-to-many roles association automatically
      many_to_many :roles, Role,
        join_through: "user_roles",
        on_delete: :delete_all,
        on_replace: :delete

      @doc """
      Checks if the user has a specific role by its slug.
      Automatically preloads roles if not already loaded.
      """
      def has_role?(user, role_slug) when is_binary(role_slug) and is_map(user) do
        user = if Ecto.assoc_loaded?(user.roles), do: user, else: Config.repo().preload(user, :roles)
        Enum.any?(user.roles, &(&1.slug == role_slug))
      end

      @doc """
      Checks if the user has any of the provided roles.
      Automatically preloads roles if not already loaded.
      """
      def has_any_role?(user, role_slugs) when is_list(role_slugs) and is_map(user) do
        user = if Ecto.assoc_loaded?(user.roles), do: user, else: Config.repo().preload(user, :roles)
        Enum.any?(user.roles, &(&1.slug in role_slugs))
      end

      @doc """
      Checks if the user has all of the provided roles.
      Automatically preloads roles if not already loaded.
      """
      def has_all_roles?(user, role_slugs) when is_list(role_slugs) and is_map(user) do
        user = if Ecto.assoc_loaded?(user.roles), do: user, else: Config.repo().preload(user, :roles)
        user_slugs = Enum.map(user.roles, & &1.slug)
        Enum.all?(role_slugs, &(&1 in user_slugs))
      end

      @doc """
      Checks if the user has a specific permission by its slug.
      Delegates to PhoenixShield.Authorization.can? but works directly on the user struct.
      """
      def can?(user, permission_slug) when is_binary(permission_slug) and is_map(user) do
        PhoenixShield.Authorization.can?(user, permission_slug)
      end

      @doc """
      Gets all permissions for the user.
      Automatically preloads all necessary associations if needed.
      """
      def get_permissions(user) when is_map(user) do
        PhoenixShield.Authorization.get_user_permissions(user)
      end
    end
  end
end
