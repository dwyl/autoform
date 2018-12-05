defmodule Autoform.CustomView do
  use Phoenix.View, root: Path.join(__DIR__, "../templates"), pattern: "**/*"
  use Phoenix.HTML
  import Phoenix.HTML.Form
  import Autoform.ErrorHelpers

  def input(form, field, schema, opts) do
    type =
      with "Elixir.Fields." <> field_type <- to_string(schema.__schema__(:type, field)),
           {:module, module} <- Code.ensure_loaded(Module.concat(Fields, field_type)),
           true <- function_exported?(module, :input_type, 0) do
        Module.concat(Fields, field_type).input_type
      else
        _ ->
          Phoenix.HTML.Form.input_type(form, field)
      end

    # Apply any sensible defaults here, but we should allow configuration of individual input options
    opts =
      Keyword.merge(
        opts,
        [value: form.source.changes[field]] ++
          case schema.__schema__(:type, field) do
            :float -> [step: 0.01]
            _ -> []
          end
      )

    apply(Phoenix.HTML.Form, type, [form, field, opts])
  end
end
