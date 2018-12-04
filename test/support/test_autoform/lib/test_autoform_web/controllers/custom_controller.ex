defmodule TestAutoformWeb.CustomController do
  use TestAutoformWeb, :controller
  alias TestAutoform.{Address, Product}

  def new(conn, _params) do
    changeset = Address.changeset(%Address{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def new_no_path(conn, _params) do
    changeset = Address.changeset(%Address{}, %{})

    render(conn, "new_no_path.html", changeset: changeset)
  end

  def new_product(conn, _params) do
    changeset = Product.changeset(%Product{}, %{})

    render(conn, "new_product.html", changeset: changeset)
  end
end
