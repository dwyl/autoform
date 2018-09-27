defmodule TestAutoformWeb.UserController do
  use TestAutoformWeb, :controller
  use Autoform

  alias TestAutoform.User

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})

    render_autoform(conn, :create, User, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    user = %User{name: "Test User", age: "55", id: id}
    changeset = User.changeset(user, %{})

    conn
    |> render_autoform(:update, User, user: user, changeset: changeset)
  end
end
