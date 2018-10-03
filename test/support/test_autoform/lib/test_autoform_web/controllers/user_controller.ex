defmodule TestAutoformWeb.UserController do
  use TestAutoformWeb, :controller
  use Autoform

  alias TestAutoform.User

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})

    render_autoform(conn, :create, User, assigns: [changeset: changeset])
  end

  def edit(conn, %{"id" => id}) do
    user = %User{name: "Test User", age: "55", address: "12 Test Road", id: id}
    changeset = User.changeset(user, %{})

    conn
    |> render_autoform(:update, User, assigns: [user: user, changeset: changeset], exclude: [:age])
  end
end
