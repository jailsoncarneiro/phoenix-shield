defmodule PhoenixShieldWeb.AuthHook do
  @moduledoc """
  LiveView on_mount hook that loads user permissions into the socket.
  Add this to your router to automatically load permissions for all LiveViews.

  Usage in router.ex:

      on_mount PhoenixShieldWeb.AuthHook
  """
  alias PhoenixShield.Authorization

  def on_mount(:default, _params, session, socket) do
    # Get the current user from the session (assuming you store user_id in session)
    user =
      if user_id = session["user_id"] do
        PhoenixShield.Repo.get(PhoenixShield.User, user_id)
      else
        nil
      end

    # Load all user permissions into the socket
    permissions = Authorization.get_user_permissions(user)
    socket = %{socket | assigns: Map.put(socket.assigns, :permissions, permissions)}

    {:cont, socket}
  end
end
