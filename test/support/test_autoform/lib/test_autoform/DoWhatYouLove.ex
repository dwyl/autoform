defmodule TestAutoform.DoWhatYouLove do
  use Ecto.Schema
  import Ecto.Changeset

  schema "do_what_you_love" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
