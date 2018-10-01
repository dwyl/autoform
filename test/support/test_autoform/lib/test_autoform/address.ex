defmodule TestAutoform.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field(:line_1, :string)
    field(:postcode, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:line_1, :postcode])
    |> validate_required([:line_1, :postcode])
  end
end
