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
      import Ecto.Query, only: [from: 2]

      @doc """
        Renders a 'create' or 'update' form based on the schema passed to it.

        ## Examples

          In a controller:

            render_autoform(conn, :update, User, assigns: [user: get_user_from_db()])

          In a template:

            <%= render_autoform(@conn, :create, User, assigns: [changeset: @changeset)], exclude: :date_of_birth %>

        ## Options

          * `:assigns` - The assigns for the form template, for example a changeset for update forms. Will default to empty list
          * `:exclude` - A list of any fields in your schema you don't want to display on the form
          * `:update_field` - The field from your schema you want to use in your update path (/users/some-id), defaults to id
          * `:assoc_query` - An ecto query you want to use when loading your associations

      """
      @spec render_autoform(
              Plug.Conn.t(),
              atom,
              Ecto.Schema.t(),
              Keyword.t() | map
            ) :: Plug.Conn.t() | {atom, String.t()} | no_return()
      def render_autoform(conn, action, schema, options \\ [])
          when action in [:update, :create] do
        assigns = Keyword.get(options, :assigns, [])

        path_data =
          case action do
            :create ->
              []

            :update ->
              {key, schema_data} =
                Enum.find(assigns, fn {k, v} ->
                  k != :changeset && match?(v, schema)
                end)

              case Keyword.get(options, :update_field) do
                nil -> schema_data
                field -> Map.get(schema_data, field)
              end
          end

        required = Map.get(schema.changeset(struct(schema), %{}), :required)

        action = path(conn, action, path_data)

        assigns =
          assigns
          |> Enum.into(%{})
          |> Map.put_new(:changeset, schema.changeset(struct(schema), %{}))
          |> Map.put(:action, action)
          |> put_fields(schema, options)
          |> Map.put(:required, required)
          |> put_associations(conn, schema, options)
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

      def custom_render(conn, action, elements) do
        excludes = [:id, :inserted_at, :updated_at]
        action = path(conn, action, [])
        changeset = List.first(elements).changeset(struct(List.first(elements)), %{})

        elements =
          Enum.map(elements, fn e ->
            case is_binary(e) do
              true ->
                {:html, raw(e)}

              false ->
                {to_string(e), e.__schema__(:fields) |> Enum.reject(&(&1 in excludes))}
            end
          end)

        IO.inspect(elements)

        Phoenix.View.render(Autoform.CustomView, "custom.html", %{
          elements: elements,
          changeset: changeset,
          action: action
        })
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

      defp put_fields(assigns, schema, options) do
        excludes = Keyword.get(options, :exclude, []) ++ [:id, :inserted_at, :updated_at]

        fields = schema.__schema__(:fields) |> Enum.reject(&(&1 in excludes))

        Map.put(assigns, :fields, fields)
      end

      defp put_associations(assigns, conn, schema, options) do
        excludes = Keyword.get(options, :exclude, [])

        assoc_query =
          Keyword.get(options, :assoc_query, fn schema -> from(s in schema, select: s) end)

        ch = Map.get(assigns, :changeset).data

        repo =
          Module.concat(
            Macro.camelize(to_string(Phoenix.Controller.endpoint_module(conn).config(:otp_app))),
            "Repo"
          )

        associations =
          schema.__schema__(:associations)
          |> Enum.reject(&(&1 in excludes))
          |> Enum.map(fn a ->
            assoc = Map.get(schema.__schema__(:association, a), :queryable)

            query =
              case is_function(assoc_query) do
                true -> assoc_query.(assoc)
                false -> nil
              end

            %{
              name: a,
              associations:
                Enum.map(
                  apply(repo, :all, [query]),
                  fn a ->
                    Map.put(a, :display, Map.get(a, :name))
                  end
                ),
              loaded_associations: apply(repo, :preload, [ch, [{a, query}]])
            }
          end)

        Map.put(assigns, :associations, associations)
      end
    end
  end
end
