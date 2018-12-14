defmodule TestAutoform.SampleProduct do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sample_products" do
    field(:price, :float)

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:price])
    |> validate_required([:price])
  end
end
