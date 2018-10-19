defmodule TestAutoformWeb.AddressController do
  use TestAutoformWeb, :controller
  alias TestAutoform.Address

  def index(conn, _params) do
    changeset = Address.changeset(%Address{}, %{})

    render(conn, "index.html", changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Address.changeset(%Address{}, %{})

    render(conn, "new.html", changeset: changeset)
  end
end
