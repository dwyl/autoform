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

Then, you'll have the `render_autoform/4` function available in the controller, or the template that corresponds to the view.

Call the function in your controller with:

``` elixir
render_autoform(conn, :update, User, assigns: [user: get_user_from_db()])
```

or in your template:
``` elixir
<%= render_autoform(@conn, :new, User, assigns: [changeset: @changeset)], exclude: :date_of_birth %>
```

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