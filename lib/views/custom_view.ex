defmodule Autoform.CustomView do
  use Phoenix.View, root: Path.join(__DIR__, "../templates"), pattern: "**/*"
  use Phoenix.HTML
  import Phoenix.HTML.Form
  import Autoform.ErrorHelpers

  def input(form, field, name, opts) do
    type = Phoenix.HTML.Form.input_type(form, field)
    apply(Phoenix.HTML.Form, type, [String.to_existing_atom(name), field, opts])
  end

  def get_label(element, field) do
    class = "control-label #{if field in element.required, do: "required"}"

    label String.to_existing_atom(element.schema_name), field, class: class do
      Map.get(element.custom_labels, field, humanize(field))
    end
  end
end
