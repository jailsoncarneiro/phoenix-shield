# PhoenixShield 🔒
A powerful, agnostic Role-Based Access Control (RBAC) library for Phoenix Framework, inspired by Filament Shield for Laravel.

## Features
- 🛡️ **Complete RBAC Engine**: Roles and permissions with many-to-many relationships
- 🎯 **Slug-based Permissions**: Clean `resource:action` format (e.g., `users:view`, `posts:create`)
- 🔍 **Automatic Permission Discovery**: Scans your LiveViews/Controllers to sync permissions to the database
- ⚡ **LiveView Ready**: Built-in on_mount hook to auto-load user permissions into the socket
- 🚀 **High Performance**: Leverages Ecto queries and Elixir's pattern matching for fast authorization checks
- 🌐 **Agnostic**: No dependencies on specific app logic, works with any Phoenix project

## Installation
1. Add PhoenixShield to your `mix.exs` dependencies:
```elixir
defp deps do
  [
    {:phoenix_shield, "~> 1.0.0-alpha"}
  ]
end
```

2. Run migrations:
```bash
mix ecto.migrate
```

## Usage

### 1. Define Permissions
Add permissions to your LiveViews or Controllers using the `@permission` macro:
```elixir
defmodule MyAppWeb.UsersLive do
  use MyAppWeb, :live_view

  @permission "users:view", "View users", "Allows viewing user list"
  @permission "users:create", "Create users", "Allows creating new users"
  @permission "users:edit", "Edit users", "Allows editing existing users"
  @permission "users:delete", "Delete users", "Allows deleting users"
  
  # ... LiveView code
end
```

### 2. Sync Permissions to Database
Run the permissions discovery to sync all defined permissions to your database:
```elixir
PhoenixShield.PermissionsDiscovery.sync_permissions_with_db()
```

### 3. Check Permissions
Use `can?` to check if a user has a specific permission:
```elixir
if PhoenixShield.Authorization.can?(current_user, "users:edit") do
  # User can edit users
end
```

### 4. LiveView Integration
Add the auth hook to your router to auto-load permissions into the socket:
```elixir
# lib/my_app_web/router.ex
defmodule MyAppWeb.Router do
  use MyAppWeb, :router
  
  on_mount PhoenixShieldWeb.AuthHook
  
  # ... routes
end
```

Check permissions directly from the socket in your LiveView:
```elixir
if PhoenixShield.Authorization.socket_can?(socket, "users:create") do
  # Show create button
end
```

## Database Schema
PhoenixShield creates these tables:
- `users` - Your application users
- `roles` - Roles that can be assigned to users
- `permissions` - Individual permissions with `resource:action` slugs
- `user_roles` - Join table for users <-> roles (many-to-many)
- `role_permissions` - Join table for roles <-> permissions (many-to-many)

## GitHub Flow
We follow the GitHub Flow workflow:
- `main` - Production-ready code
- `develop` - Integration branch for new features
- Feature branches: `feature/your-feature-name`
- Bugfix branches: `fix/your-bug-name`

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request to `develop`

## License
PhoenixShield is released under the MIT License.