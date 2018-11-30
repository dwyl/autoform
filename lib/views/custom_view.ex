defmodule Autoform.CustomView do
  use Phoenix.View, root: Path.join(__DIR__, "../templates"), pattern: "**/*"
  use Phoenix.HTML
  import Phoenix.HTML.Form
  import Autoform.ErrorHelpers

  def input(form, field, name, schema, opts) do
    type =
      with "Elixir.Fields." <> field_type <- to_string(schema.__schema__(:type, field)),
           {:module, module} <- Code.ensure_loaded(Module.concat(Fields, field_type)),
           true <- function_exported?(module, :input_type, 0) do
        Module.concat(Fields, field_type).input_type
      else
        _ ->
          Phoenix.HTML.Form.input_type(form, field)
      end

    apply(Phoenix.HTML.Form, type, [String.to_existing_atom(name), field, opts])
  end
end
