defmodule PhoenixShield.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    field :slug, :string
    field :description, :string

    many_to_many :permissions, PhoenixShield.Permission,
      join_through: "role_permissions",
      on_delete: :delete_all,
      on_replace: :delete

    many_to_many :users, PhoenixShield.User,
      join_through: "user_roles",
      on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
    |> put_assoc(:permissions, attrs[:permissions] || [])
  end
end
