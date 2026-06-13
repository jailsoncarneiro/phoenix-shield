defmodule PhoenixShieldWeb.PageController do
  use PhoenixShieldWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
