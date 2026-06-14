defmodule PhoenixShieldWeb.RoleManagementLive do
  @moduledoc """
  LiveView for managing roles and permissions in a modern, Filament Shield-style matrix view.
  Permissions grouped by resource, with cards, select all toggles, and real-time updates.
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

    # Group permissions by their resource field
    permissions_by_resource = Enum.group_by(permissions, & &1.resource)
    resource_names = Map.keys(permissions_by_resource) |> Enum.sort()

    socket = assign(socket,
      roles: roles,
      permissions: permissions,
      permissions_by_resource: permissions_by_resource,
      resource_names: resource_names,
      role_permissions: get_role_permissions_map(roles, repo)
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_permission", %{"role_id" => role_id, "permission_id" => permission_id}, socket) do
    repo = Config.repo()
    role = repo.get(Role, role_id) |> repo.preload(:permissions)
    permission = repo.get(Permission, permission_id)

    has_permission? = Enum.any?(role.permissions, &(&1.id == permission.id))

    changeset =
      if has_permission? do
        Role.changeset(role, %{})
        |> Changeset.put_assoc(:permissions, Enum.filter(role.permissions, &(&1.id != permission.id)))
      else
        Role.changeset(role, %{})
        |> Changeset.put_assoc(:permissions, role.permissions ++ [permission])
      end

    {:ok, role} = repo.update(changeset)
    role = repo.preload(role, :permissions)

    roles = Enum.map(socket.assigns.roles, fn r -> if r.id == role.id, do: role, else: r end)
    role_permissions = get_role_permissions_map(roles, repo)

    socket = assign(socket, roles: roles, role_permissions: role_permissions)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_resource_all", %{"role_id" => role_id, "resource" => resource}, socket) do
    repo = Config.repo()
    role = repo.get(Role, role_id) |> repo.preload(:permissions)

    # Get all permissions for this resource
    resource_permissions = from(p in Permission, where: p.resource == ^resource) |> repo.all()
    resource_permission_ids = MapSet.new(Enum.map(resource_permissions, & &1.id))

    # Get currently assigned permissions for this role
    current_permission_ids = MapSet.new(Enum.map(role.permissions, & &1.id))

    # Check if all are already selected (we'll toggle to the opposite state)
    all_selected? = MapSet.subset?(resource_permission_ids, current_permission_ids)

    # Calculate new permissions
    new_permissions =
      if all_selected? do
        # Remove all permissions from this resource
        Enum.filter(role.permissions, &(&1.resource != resource))
      else
        # Add all missing permissions from this resource
        missing = Enum.filter(resource_permissions, &(&1.id not in current_permission_ids))
        role.permissions ++ missing
      end

    # Batch update all permissions in a single database call
    changeset = Role.changeset(role, %{}) |> Changeset.put_assoc(:permissions, new_permissions)
    {:ok, role} = repo.update(changeset)
    role = repo.preload(role, :permissions)

    roles = Enum.map(socket.assigns.roles, fn r -> if r.id == role.id, do: role, else: r end)
    role_permissions = get_role_permissions_map(roles, repo)

    socket = assign(socket, roles: roles, role_permissions: role_permissions)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_role_all", %{"role_id" => role_id}, socket) do
    repo = Config.repo()
    role = repo.get(Role, role_id) |> repo.preload(:permissions)
    all_permissions = repo.all(Permission)

    current_permission_ids = MapSet.new(Enum.map(role.permissions, & &1.id))
    all_selected? = MapSet.size(current_permission_ids) == length(all_permissions)

    new_permissions = if all_selected?, do: [], else: all_permissions

    changeset = Role.changeset(role, %{}) |> Changeset.put_assoc(:permissions, new_permissions)
    {:ok, role} = repo.update(changeset)
    role = repo.preload(role, :permissions)

    roles = Enum.map(socket.assigns.roles, fn r -> if r.id == role.id, do: role, else: r end)
    role_permissions = get_role_permissions_map(roles, repo)

    socket = assign(socket, roles: roles, role_permissions: role_permissions)
    {:noreply, socket}
  end

  # Helper function to build a map: %{role_id => MapSet of permission_ids}
  defp get_role_permissions_map(roles, repo) do
    Enum.reduce(roles, %{}, fn role, acc ->
      role = repo.preload(role, :permissions)
      permission_ids = MapSet.new(Enum.map(role.permissions, & &1.id))
      Map.put(acc, role.id, permission_ids)
    end)
  end

  # Helper to check if all permissions in a resource are selected for a role
  defp all_resource_selected?(role_permissions, role_id, resource_permissions) do
    permission_ids = Map.get(role_permissions, role_id, MapSet.new())
    Enum.all?(resource_permissions, &(&1.id in permission_ids))
  end

  # Helper to check if all permissions are selected for a role
  defp all_role_selected?(role_permissions, role_id, all_permissions) do
    permission_ids = Map.get(role_permissions, role_id, MapSet.new())
    MapSet.size(permission_ids) == length(all_permissions)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 py-8 px-4 sm:px-6 lg:px-8">
      <div class="max-w-7xl mx-auto">
        <!-- Page Header -->
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-base-content">Role Permissions Management</h1>
          <p class="mt-2 text-sm text-base-content/70">Manage permissions across all roles in your application</p>
        </div>

        <!-- Single Fixed-Layout Table for Perfect Alignment -->
        <div class="overflow-x-auto">
          <table class="w-full table-fixed bg-base-100 rounded-xl shadow-sm border border-base-300">
            <!-- Sticky Header that stays at the top when scrolling -->
            <thead class="sticky top-0 z-50 bg-base-300 shadow-sm border-b-2 border-base-300">
              <tr>
                <!-- First column fixed for permissions -->
                <th class="w-1/3 px-6 py-4 text-left font-semibold text-base-content">Permissions / Roles</th>
                <!-- Fixed width columns for each role to ensure perfect alignment -->
                <%= for role <- @roles do %>
                  <th class="w-32 px-2 py-4 text-center">
                    <div class="flex flex-col items-center gap-2">
                      <span class="text-xs font-semibold text-base-content uppercase tracking-wide"><%= role.name %></span>
                      <input
                        type="checkbox"
                        class="checkbox checkbox-primary checkbox-sm"
                        checked={all_role_selected?(@role_permissions, role.id, @permissions)}
                        phx-click="toggle_role_all"
                        phx-value-role_id={role.id}
                        title={"Select all for #{role.name}"}
                      />
                    </div>
                  </th>
                <% end %>
              </tr>
            </thead>

            <tbody>
              <!-- Group permissions by resource - each resource gets its own section -->
              <%= for resource <- @resource_names do %>
                <% resource_perms = @permissions_by_resource[resource] %>
                <!-- Resource Group Header Row - SAME CELL STRUCTURE as all other rows! -->
                <tr class="bg-base-300 border-b-2 border-base-300">
                  <!-- First cell (matches w-1/3 of all rows) -->
                  <td class="w-1/3 px-6 py-4">
                    <div class="flex items-center gap-3">
                      <!-- Fixed size SVG icon -->
                      <svg class="w-6 h-6 text-base-content/60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                      </svg>
                      <span class="font-bold text-base-content capitalize text-lg"><%= String.capitalize(resource) %></span>
                      <span class="text-sm text-base-content/60">(<%= length(resource_perms) %> permissions)</span>
                    </div>
                  </td>
                  <!-- Resource-level Select All checkboxes - SAME w-32 as all role columns! -->
                  <%= for role <- @roles do %>
                    <td class="w-32 px-2 py-4 text-center">
                      <input
                        type="checkbox"
                        class="checkbox checkbox-primary checkbox-sm"
                        checked={all_resource_selected?(@role_permissions, role.id, resource_perms)}
                        phx-click="toggle_resource_all"
                        phx-value-role_id={role.id}
                        phx-value-resource={resource}
                      />
                    </td>
                  <% end %>
                </tr>

                <!-- Individual Permission Rows for this resource -->
                <%= for perm <- resource_perms do %>
                  <tr class="border-b border-base-300 hover:bg-base-200 transition-colors">
                    <!-- Permission details - same w-1/3 -->
                    <td class="px-6 py-3 text-left">
                      <div class="text-sm font-medium text-base-content"><%= perm.name %></div>
                      <div class="text-xs text-base-content/60 mt-0.5"><%= perm.slug %></div>
                    </td>
                    <!-- Checkboxes for each role - same w-32, perfectly aligned! -->
                    <%= for role <- @roles do %>
                      <td class="w-32 px-2 py-3 text-center">
                        <input
                          type="checkbox"
                          class="checkbox checkbox-primary checkbox-sm cursor-pointer"
                          checked={Map.get(@role_permissions, role.id, %{}) |> MapSet.member?(perm.id)}
                          phx-click="toggle_permission"
                          phx-value-role_id={role.id}
                          phx-value-permission_id={perm.id}
                        />
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end
end
