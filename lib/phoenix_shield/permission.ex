defmodule PhoenixShield.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :name, :string
    field :slug, :string
    field :resource, :string
    field :action, :string
    field :description, :string

    many_to_many :roles, PhoenixShield.Role,
      join_through: "role_permissions",
      on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:name, :slug, :resource, :action, :description])
    |> validate_required([:name, :slug, :resource, :action])
    |> unique_constraint(:slug)
    |> validate_format(:slug, ~r/^[\w-]+:[\w-]+$/, message: "must be in format 'resource:action'")
  end
end
