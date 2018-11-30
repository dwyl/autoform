defmodule TestAutoform.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:age, :integer)
    field(:name, :string)
    field(:address, :string)
    field(:biography, Fields.DescriptionPlaintextUnlimited)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :age, :biography])
    |> validate_required([:name, :age])
  end
end
