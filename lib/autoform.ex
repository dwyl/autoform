defmodule Autoform do
  @excludes [:id, :inserted_at, :updated_at]

  @moduledoc """
  Documentation for Autoform.
  """

  @doc """
  Autoform provides functions that can be used in a Phoenix Controller or View
  to generate a form using an Ecto Schema.

  Usage:

  At the top of your controller or view file, call:

      use Autoform

  then, when you want to render your form, call `render_autoform`/4, or `custom_render_autoform/4`
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      import Ecto.Query, only: [from: 2]

      @doc """
        Renders a 'create' or 'update' form based on the schema passed to it.
        Can be used in a Phoenix Controller or View.

        ## Examples

          In a controller:

            render_autoform(conn, :update, User, assigns: [user: get_user_from_db()])

          In a template:

            <%= render_autoform(@conn, :create, User, assigns: [changeset: @changeset)], exclude: [:date_of_birth] %>

        ## Options

          * `:assigns` - The assigns for the form template, for example a changeset for update forms. Will default to empty list
          * `:exclude` - A list of any fields in your schema you don't want to display on the form
          * `:update_field` - The field from your schema you want to use in your update path (/users/some-id), defaults to id
          * `:assoc_query` - An ecto query you want to use when loading your associations
          * `:btn_txt` - A string that will be used in the form submission button

      """
      @spec render_autoform(
              Plug.Conn.t(),
              atom(),
              Ecto.Schema.t(),
              Keyword.t() | map()
            ) :: Plug.Conn.t() | {atom(), String.t()} | no_return()
      def render_autoform(conn, action, schema, options \\ [])
          when action in [:update, :create] do
        assigns = create_assigns(conn, action, schema, options)

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

      defp create_assigns(conn, action, schema, options) do
        assigns = Keyword.get(options, :assigns, [])

        required = Map.get(schema.changeset(struct(schema), %{}), :required)

        assigns =
          assigns
          |> submit_btn_txt(options)
          |> Enum.into(%{})
          |> Map.put_new(:changeset, schema.changeset(struct(schema), %{}))
          |> Map.put(:action, path(conn, action, schema, options))
          |> Map.put(:fields, fields(schema, options))
          |> Map.put(:required, required)
          |> (fn a ->
                Map.put(a, :associations, associations(conn, schema, a.changeset, options))
              end).()
          |> Map.put(:schema_name, schema_name(schema))
      end

      @doc """
        Takes a list of Ecto Schemas, HTML strings or a tuple of Ecto Schemas and options, and renders a form using them.

        ## Examples

            <%= custom_render_autoform(@conn, :create, [
              User,
              "<h1>Title goes here</h1>",
              {Address, exclude: [:line_2], custom_labels: %{line_1: "Street Name"}}
            ], assigns: [changeset: @changeset)], exclude: [:entry_id] %>

            <%= custom_render_autoform(@conn, :update, [{Address, input_first: [:line_1, :postcode],}], assigns: [changeset: @changeset)] %>


        ## Schema Options

        Pass these as the second element in a tuple, where the schema is the first.

          * `:exclude` - A list of any fields from this schema you don't want to display.
          * `:custom_labels` - A map where the key is your field name, and the value is what you want to display as the label for that field.
          * `:input_first` - A list of any fields from this schema where you would like to display the input followed by the label.

        ## Global Options

        Pass these as the final argument to `custom_render_autoform`

          * `:exclude` - A list of any fields in any of your schemas you don't want to display on the form
          * `:update_field` - The field from your schema you want to use in your update path (/users/some-id), defaults to id
          * `:assoc_query` - An ecto query you want to use when loading your associations
          * `:path` - The endpoint you want your form to post to. Defaults using the calling modules schema name plus :update_field. If you are rendering multiple schemas, you will almost certainly need to use this field
          * `:btn_txt` - A string that will be used in the form submission button

      """
      @spec custom_render_autoform(
              Plug.Conn.t(),
              atom(),
              list(Ecto.Schema.t() | tuple() | String.t()),
              Keyword.t() | map()
            ) :: {atom(), String.t()} | no_return()
      def custom_render_autoform(conn, action, elements, options \\ []) do
        element_assigns =
          Enum.map(elements, fn e ->
            case is_binary(e) do
              true ->
                %{html: Phoenix.HTML.raw(e)}

              false ->
                {schema, schema_options} =
                  case e do
                    {schema, opts} -> {schema, opts}
                    _ -> {e, []}
                  end

                excludes = Keyword.get(schema_options, :exclude, [])
                custom_labels = Keyword.get(schema_options, :custom_labels, %{})
                input_first = Keyword.get(schema_options, :input_first, [])

                %{
                  fields:
                    fields(
                      schema,
                      Keyword.update(options, :exclude, excludes, fn v ->
                        v ++ excludes
                      end)
                    ),
                  required: Map.get(schema.changeset(struct(schema), %{}), :required),
                  associations:
                    associations(
                      conn,
                      schema,
                      Keyword.get(
                        Keyword.get(options, :assigns, []),
                        :changeset,
                        schema.changeset(struct(schema), %{})
                      ),
                      Keyword.update(options, :exclude, [], fn v -> v ++ excludes end)
                    ),
                  schema_name: schema_name(schema),
                  custom_labels: custom_labels,
                  input_first: input_first,
                  schema: schema
                }
            end
          end)

        first_schema =
          Enum.find(elements, fn e -> not is_binary(e) end)
          |> case do
            {schema, _} -> schema
            schema -> schema
          end

        Phoenix.View.render(
          Autoform.CustomView,
          "custom.html",
          Keyword.get(options, :assigns, [])
          |> submit_btn_txt(options)
          |> Map.new()
          |> Map.put_new(:changeset, first_schema.changeset(struct(first_schema), %{}))
          |> (fn m ->
                Map.merge(m, %{
                  elements: element_assigns,
                  action: Keyword.get(options, :path, path(conn, action, first_schema, options)),
                  assoc_list: Map.get(m, :changeset).data.__struct__.__schema__(:associations)
                })
              end).()
        )
      end

      defp path(conn, action, schema, options) do
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

        regex = ~r/(?<web_name>.+)\.(?<schema_name>.+)(?<module_type>Controller|View)/

        %{"web_name" => web_name, "schema_name" => schema_name} =
          Regex.named_captures(regex, to_string(__MODULE__))

        apply(
          String.to_existing_atom(web_name <> ".Router.Helpers"),
          String.to_existing_atom(Macro.underscore(schema_name) <> "_path"),
          [conn, action, path_data]
        )
      end

      defp fields(schema, options) do
        excludes = Keyword.get(options, :exclude, []) ++ unquote(@excludes)

        schema.__schema__(:fields)
        |> Enum.reject(&(&1 in excludes))
      end

      defp associations(conn, schema, changeset, options) do
        excludes = Keyword.get(options, :exclude, []) ++ unquote(@excludes)

        assoc_query =
          Keyword.get(options, :assoc_query, fn schema -> from(s in schema, select: s) end)

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
              cardinality: Map.get(schema.__schema__(:association, a), :cardinality),
              name: a,
              associations:
                Enum.map(
                  apply(repo, :all, [query]),
                  fn a ->
                    Map.put(a, :display, Map.get(a, :name))
                  end
                ),
              loaded_associations:
                apply(repo, :preload, [Map.get(changeset, :data, %{}), [{a, query}]])
            }
          end)

        associations
      end

      defp schema_name(schema) do
        schema |> to_string() |> String.downcase() |> String.split(".") |> List.last()
      end

      defp submit_btn_txt(assigns, options) do
        btn_txt_str = Keyword.get(options, :btn_txt, "Save")
        Keyword.put_new(assigns, :btn_txt, btn_txt_str)
      end
    end
  end
end
