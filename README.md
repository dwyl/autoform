# af
Auto Form ("af") is a way of generating standards/WCAG compliant HTML forms based on an Ecto Schema.

## Usage

Add autoform to your mix.exs

``` elixir
defp deps do
    [
      {:autoform, "~> 0.1.0"}
    ]
  end
```

Autoform can be used from either a Phoenix View, or Phoenix Controller.

You'll need to add
``` elixir
use Autoform
```

to the top of the module you want to use it in.

You'll be able to call either `render_autoform/4` or `custom_render_autoform/4` in the controller, or the template that corresponds to the view.

Call `render_autoform` in your controller with:

``` elixir
render_autoform(conn, :update, User, assigns: [user: get_user_from_db()])
```

or in your template:
``` elixir
<%= render_autoform(@conn, :create, User, assigns: [changeset: @changeset)], exclude: :date_of_birth %>
```

`custom_render_autoform` is called in a very similar way, but can be given extra arguments which will change the generated form.

An example of this in a template:
``` elixir
<%= custom_render_autoform(@conn, :create, [{User, custom_labels: %{date_of_birth: "DOB"}, input_first: [:date_of_birth]}], assigns: [changeset: @changeset)] %>
```
This will now render the form with a custom label for the `date_of_birth` input field.

### Arguments

``` elixir
render_autoform(conn, action, schema, options)
```

- conn : Your Phoenix Plug.Conn

- action : Either `:update` or `:create`. This will be used to create the endpoint for your form.

- schema : Your Ecto schema

- options : A list of options you can use to customise your forms.
  - `:assigns` - The assigns for the form template, for example a changeset for update forms. Will default to empty list
  - `:exclude` - A list of any fields in your schema you don't want to display on the form
  -  `:update_field` - The field from your schema you want to use in your update path (/users/some-id), defaults to `id`
  - `:assoc_query` - An ecto query you want to use when loading your associations

``` elixir
custom_render_autoform(conn, action, [{schema, opts}], options)
```

- conn : Your Phoenix Plug.Conn

- action : Either `:update` or `:create`. This will be used to create the endpoint for your form.

- list {schema, opts} : A list of tuples which contain your Ecto schemas and the options for the form.
  - opts include:
    - `:custom_labels` - A map with a key of the field from your schema and a value of text you would like to label the input with.
    - `:input_first` - A list of fields where you would like to display the label followed by the input.

- options : A list of options you can use to customise your forms.
  - `:assigns` - The assigns for the form template, for example a changeset for update forms. Will default to empty list
  - `:exclude` - A list of any fields in your schema you don't want to display on the form
  -  `:update_field` - The field from your schema you want to use in your update path (/users/some-id), defaults to `id`
  - `:assoc_query` - An ecto query you want to use when loading your associations

### Associations

`:many_to_many` associations are rendered as checkboxes.

`:belongs_to` associations are rendered as a `select` element.

If you don't want the associations to be rendered in your form, you can add them to your exclude list (see options `above`).

### Fields

This module can be used in conjuction with https://github.com/dwyl/fields.

If you use one of these Fields in your schema, and that field has an `input_type/0` callback. The result of that callback will be the input type that is rendered in your form.

For example, the field `Fields.DescriptionPlaintextUnlimited` returns `:textarea` from its `input_type` function, so `autoform` will render a textarea using [`Phoenix.HTML.Form.textarea/3`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#textarea/3)