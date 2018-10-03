defmodule Autoform do
  @moduledoc """
  Documentation for Autoform.
  """

  @doc """
  Autoform provides a function that can be used in a Phoenix Controller or View
  to generate a form using an Ecto Schema.

  Usage:

  At the top of your controller or view file, call:

      use Autoform

  then, when you want to render your form, call render_autoform/4
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      @doc """
        Renders a 'new' or 'update' form based on the schema passed to it.

        Example:
          In a controller:
            render_autoform(conn, :update, User, user: get_user_from_db())

          In a template:
            <%= render_autoform(@conn, :new, User, changeset: @changeset) %>
      """
      @spec render_autoform(Plug.Conn.t(), atom, Ecto.Schema.t(), Keyword.t() | map) ::
              Plug.Conn.t()
      def render_autoform(conn, action, schema, assigns) when action in [:update, :create] do
        fields =
          schema.__schema__(:fields)
          |> Enum.reject(&(&1 in [:id, :inserted_at, :updated_at]))

        {_key, schema_data} =
          case action do
            :create -> {nil, []}
            :update -> Enum.find(assigns, fn {_k, v} -> match?(v, schema) end)
          end

        required = Map.get(schema.changeset(struct(schema), %{}), :required)

        action = path(conn, action, schema_data)

        assigns =
          assigns
          |> Enum.into(%{})
          |> Map.put(:action, action)
          |> Map.put(:fields, fields)
          |> Map.put(:required, required)
          |> put_associations(conn, schema)
          |> Map.put(
            :schema_name,
            to_string(schema) |> String.downcase() |> String.split(".") |> List.last()
          )

        cond do
          Regex.match?(~r/.+Controller$/, to_string(__MODULE__)) ->
            conn
            |> Phoenix.Controller.put_view(Autoform.AutoformView)
            |> Phoenix.Controller.render("form.html", assigns)

          Regex.match?(~r/.+View$/, to_string(__MODULE__)) ->
            Phoenix.View.render(Autoform.AutoformView, "form.html", assigns)

          true ->
            raise "This function must be called from a Controller or a View"
        end
      end

      defp path(conn, action, opts) do
        regex = ~r/(?<web_name>.+)\.(?<schema_name>.+)(?<module_type>Controller|View)/

        %{"web_name" => web_name, "schema_name" => schema_name} =
          Regex.named_captures(regex, to_string(__MODULE__))

        apply(
          String.to_existing_atom(web_name <> ".Router.Helpers"),
          String.to_existing_atom(String.downcase(schema_name) <> "_path"),
          [conn, action, opts]
        )
      end

      defp put_associations(assigns, conn, schema) do
        repo =
          Module.concat(
            Macro.camelize(to_string(Phoenix.Controller.endpoint_module(conn).config(:otp_app))),
            "Repo"
          )

        associations =
          Enum.map(schema.__schema__(:associations), fn a ->
            assoc = Map.get(schema.__schema__(:association, a), :queryable)

            %{
              name: a,
              associations: apply(repo, :all, [assoc])
            }
          end)

        Map.put(assigns, :associations, associations)
      end
    end
  end
end
