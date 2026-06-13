defmodule PhoenixShieldWeb.RoleManagementLive do
  @moduledoc """
  LiveView for managing roles and permissions in a matrix view: permissions as rows, roles as columns, checkboxes to sync in real-time.
  """
  use Phoenix.LiveView
  import Ecto.Query
  alias PhoenixShield.Config
  alias PhoenixShield.Role
  alias PhoenixShield.Permission
  alias Ecto.Changeset

  @impl true
  def mount(_params, _session, socket) do
    repo = Config.repo()
    roles = repo.all(Role)
    permissions = repo.all(from p in Permission, order_by: [p.resource, p.action])

    socket = assign(socket,
      roles: roles,
      permissions: permissions,
      role_permissions: get_role_permissions_map(roles, repo)
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_permission", %{"role_id" => role_id, "permission_id" => permission_id}, socket) do
    repo = Config.repo()
    role = repo.get(Role, role_id) |> repo.preload(:permissions)
    permission = repo.get(Permission, permission_id)

    # Check if permission is already assigned
    has_permission? = Enum.any?(role.permissions, &(&1.id == permission.id))

    changeset =
      if has_permission? do
        # Remove permission
        Role.changeset(role, %{})
        |> Changeset.put_assoc(:permissions, Enum.filter(role.permissions, &(&1.id != permission.id)))
      else
        # Add permission
        Role.changeset(role, %{})
        |> Changeset.put_assoc(:permissions, role.permissions ++ [permission])
      end

    {:ok, role} = repo.update(changeset)
    role = repo.preload(role, :permissions)

    # Update the roles and role_permissions map
    roles = Enum.map(socket.assigns.roles, fn r -> if r.id == role.id, do: role, else: r end)
    role_permissions = get_role_permissions_map(roles, repo)

    socket = assign(socket, roles: roles, role_permissions: role_permissions)
    {:noreply, socket}
  end

  # Helper function to build a map: %{role_id => %{permission_id => true/false}}
  defp get_role_permissions_map(roles, repo) do
    Enum.reduce(roles, %{}, fn role, acc ->
      role = repo.preload(role, :permissions)
      permission_ids = MapSet.new(Enum.map(role.permissions, & &1.id))
      Map.put(acc, role.id, permission_ids)
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Role Permissions Management</h1>

      <div class="overflow-x-auto">
        <table class="min-w-full bg-white border border-gray-200 shadow-md">
          <thead>
            <tr class="bg-gray-100 border-b">
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider sticky left-0 bg-gray-100 z-10">
                Permission
              </th>
              <%= for role <- @roles do %>
                <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <%= role.name %>
                </th>
              <% end %>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <%= for permission <- @permissions do %>
              <tr class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap sticky left-0 bg-white hover:bg-gray-50">
                  <div class="text-sm font-medium text-gray-900"><%= permission.name %></div>
                  <div class="text-xs text-gray-500"><%= permission.slug %></div>
                </td>
                <%= for role <- @roles do %>
                  <td class="px-6 py-4 whitespace-nowrap text-center">
                    <input
                      type="checkbox"
                      class="w-5 h-5 rounded border-gray-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                      checked={Map.get(@role_permissions, role.id, %{}) |> MapSet.member?(permission.id)}
                      phx-click="toggle_permission"
                      phx-value-role_id={role.id}
                      phx-value-permission_id={permission.id}
                    />
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
