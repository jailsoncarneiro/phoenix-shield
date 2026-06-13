defmodule PhoenixShield.Authorization do
  @moduledoc """
  Main authorization module for PhoenixShield. Provides the can? function to check permissions.
  """
  import Ecto.Query
  alias PhoenixShield.Config
  alias PhoenixShield.Permission

  @doc """
  Checks if a user has the required permission.

  ## Examples

      iex> PhoenixShield.Authorization.can?(user, "users:view")
      true

      iex> PhoenixShield.Authorization.can?(user, "posts:delete")
      false
  """
  def can?(user, permission_slug) when is_binary(permission_slug) do
    # If user is nil (guest), only check if it's a public permission (we can extend this)
    if is_nil(user) do
      false
    else
      # Query to check if the user has any role that includes the requested permission
      query =
        from p in Permission,
        join: rp in "role_permissions", on: p.id == rp.permission_id,
        join: ur in "user_roles", on: rp.role_id == ur.role_id,
        where: ur.user_id == ^user.id,
        where: p.slug == ^permission_slug,
        select: count(p.id)

      Config.repo().one(query) > 0
    end
  end

  @doc """
  Gets all permissions for a user, returns a list of permission slugs.
  """
  def get_user_permissions(user) do
    if is_nil(user) do
      []
    else
      query =
        from p in Permission,
        join: rp in "role_permissions", on: p.id == rp.permission_id,
        join: ur in "user_roles", on: rp.role_id == ur.role_id,
        where: ur.user_id == ^user.id,
        select: p.slug

      Config.repo().all(query)
    end
  end

  @doc """
  Checks permissions from the socket's preloaded permissions (faster, no DB query)
  """
  def socket_can?(socket, permission_slug) do
    permissions = socket.assigns[:permissions] || []
    permission_slug in permissions
  end
end
