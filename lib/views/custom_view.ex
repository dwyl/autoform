defmodule Autoform.CustomView do
  use Phoenix.View, root: Path.join(__DIR__, "../templates"), pattern: "**/*"
  use Phoenix.HTML
  import Phoenix.HTML.Form
  import Autoform.ErrorHelpers

  def input(form, field, name, opts) do
    type = Phoenix.HTML.Form.input_type(form, field)
    apply(Phoenix.HTML.Form, type, [String.to_existing_atom(name), field, opts])
  end
end
