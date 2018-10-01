defmodule TestAutoformWeb.AddressController do
  use TestAutoformWeb, :controller
  alias TestAutoform.Address

  def new(conn, _params) do
    changeset = Address.changeset(%Address{}, %{})

    render(conn, "new.html", changeset: changeset)
  end
end
